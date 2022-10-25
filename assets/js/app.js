import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import Alpine from 'alpinejs';
window.Alpine = Alpine;
Alpine.start();

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

var users = {}
var localStream

async function initStream () {
  const stream = await navigator.mediaDevices.getUserMedia({audio: true, video: true, width: "1280"})
  localStream = stream
  document.getElementById("local-video").srcObject = stream
}

function addUserConnection(userUuid) {
  if (users[userUuid] === undefined) {
    users[userUuid] = {
      peerConnection: null
    }
  }

  return users;
}

function removeUserConnection(userUuid) {
  delete users[userUuid]

  return users;
}

function createPeerConnection(lv, fromUser, offer) {
  let newPeerConnection = new RTCPeerConnection({
    iceServers: [
      { urls: "stun:petalvoicechat.com:3478" }
    ]
  })

  users[fromUser].peerConnection = newPeerConnection;

  localStream.getTracks().forEach(track => newPeerConnection.addTrack(track, localStream))

  if (offer !== undefined) {
    newPeerConnection.setRemoteDescription({type: "offer", sdp: offer})
    newPeerConnection.createAnswer()
      .then((answer) => {
        newPeerConnection.setLocalDescription(answer)
        console.log("Sending this ANSWER to the requester:", answer)
        lv.pushEvent("new_answer", {toUser: fromUser, description: answer})
      })
      .catch((err) => console.log(err))
  }

  newPeerConnection.onicecandidate = async ({candidate}) => {
    lv.pushEvent("new_ice_candidate", {toUser: fromUser, candidate})
  }

  if (offer === undefined) {
    newPeerConnection.onnegotiationneeded = async () => {
      
    newPeerConnection.createOffer()
      .then((offer) => {
        newPeerConnection.setLocalDescription(offer)
        console.log("Sending this OFFER to the requester:", offer)
        lv.pushEvent("new_sdp_offer", {toUser: fromUser, description: offer})
      })
      .catch((err) => console.log(err))
    }
  }

  newPeerConnection.ontrack = async (event) => {
    console.log("Track received:", event)
    document.getElementById(`video-remote-${fromUser}`).srcObject = event.streams[0]
  }

  return newPeerConnection;
}

let Hooks = {}
Hooks.JoinCall = {
  mounted() {
    initStream()
  }
}

Hooks.HandleOfferRequest = {
  mounted () {
    let fromUser = this.el.dataset.fromUserUuid

    console.log("new offer request from", fromUser)

    createPeerConnection(this, fromUser)
  }
}

Hooks.HandleIceCandidateOffer = {
  mounted () {
    let data = this.el.dataset
    let fromUser = data.fromUserUuid
    let iceCandidate = JSON.parse(data.iceCandidate)
    let peerConnection = users[fromUser].peerConnection

    console.log("new ice candidate from", fromUser, iceCandidate)

    peerConnection.addIceCandidate(iceCandidate)
  }
}

Hooks.HandleSdpOffer = {
  mounted () {
    let data = this.el.dataset
    let fromUser = data.fromUserUuid
    let sdp = data.sdp

    if (sdp != "") {
      console.log("new sdp OFFER from", data.fromUserUuid, data.sdp)

      createPeerConnection(this, fromUser, sdp)
    }
  }
}

Hooks.HandleAnswer = {
  mounted () {
    let data = this.el.dataset
    let fromUser = data.fromUserUuid
    let sdp = data.sdp
    let peerConnection = users[fromUser].peerConnection

    if (sdp != "") {
      console.log("new sdp ANSWER from", fromUser, sdp)
      peerConnection.setRemoteDescription({type: "answer", sdp: sdp})
    }
  }
}

Hooks.InitUser = {
  mounted () {
    addUserConnection(this.el.dataset.userUuid)
  },

  destroyed () {
    removeUserConnection(this.el.dataset.userUuid)
  }
}

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

liveSocket.connect()

window.liveSocket = liveSocket
