var sentinel_id = document.getElementById("app-interact").getAttribute('data-sentinelid');
var server = document.getElementById("app-interact").getAttribute('data-server');
var walker = document.getElementById("app-interact").getAttribute('data-walkername');
var token = document.getElementById("app-interact").getAttribute('data-token');
var last_jid = null;
var last_title = null;
var last_intent = null;

// // Replace the script tag with the app
document.getElementById('app-interact').parentNode.innerHTML = `
<div id="chatio__${sentinel_id}">
  <div class="chat-bar-collapsible">
        <button id="chat-button" type="button" class="collapsible active">Chat with us!
            <i id="chat-icon" style="color: #fff;" class="fa fa-fw fa-comments-o"></i>
        </button>

        <div class="content">
            <div class="full-chat-block">
                <!-- Message Container -->
                <div class="outer-container">
                    <div class="chat-container">
                        <!-- Messages -->
                        <div id="chatbox">
                            <h5 id="chat-timestamp"></h5>
                            <!-- <p id="botStarterMessage" class="botText"><span>Loading...</span></p> -->
                        </div>

                        <!-- User input box -->
                        <div class="chat-bar-input-block">
                            <div id="userInput">
                                <input id="chatio__inputField" class="input-box" type="text" name="msg"
                                    placeholder="ask me something...">
                                <p></p>
                            </div>

                            <div class="chat-bar-icons">
                                <i id="chat-icon" style="color: #333;" class="fa fa-fw fa-send"
                                    onclick="sendButton()"></i>
                            </div>
                        </div>

                        <div id="chat-bar-bottom">
                            <p></p>
                        </div>

                    </div>
                </div>

            </div>
        </div>

    </div>
</div>`;


var inputField = document.getElementById('chatio__inputField');

var chat_messages = [];
//  $.ajax({
//     type: "GET",
//     async: false,
//     url: "../csr-bot/chat_data.json",
//     data: {},
//     success: function(chat_data){
//         console.log(chat_data);
//         chat_messages = chat_data; 
//     },
// });

function extractEmails(text){
  return text.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/gi);
}

function detectURLs(text) {
  var urlRegex = /(((https?:\/\/)|(www\.))[^\s]+)/g;
  return text.match(urlRegex)
}

if (chat_messages.length < 1){
  chat_messages = [["bot", "Welcome to V75 Inc. How can we help you today?"]];
}

let conv = "";
let new_message = "";
update_messages();

function meeting_msg() {
  chat_messages.push(["bot", "If you'd like, We'll be happy to set up a meeting with one of our developers."]);
  chat_messages.push(["bot", "Please give us a call on +592-660-1234 or send us an email at <a href='mailto:operations@v75inc.com'>operations@v75inc.com</a>"]);
}

function sendButton(){
    var utterance = inputField.value;
    chat_messages.push(["user", utterance]);

    walker_run('talker', utterance, last_jid).then((result) => {

      // console.log(result.report[0].message);
      // console.log(result.report[0].node.jid);
      // console.log(last_title);

      // chat_messages.push(["user", utterance]);

      if(result.report[0]) {

        if (result.report[0].message){
          message = result.report[0].message;
          if (extractEmails(message)){
            message = message.replace(extractEmails(message), "<a href='mailto:"+extractEmails(message)+"'>"+extractEmails(message)+"</a>");
          }
          if (detectURLs(message)){
            message = message.replace(detectURLs(message), "<a href='"+detectURLs(message)+"' target='_blank'>"+detectURLs(message)+"</a>");
          }
          chat_messages.push(["bot", message]);
        }
        update_messages();

        //if we have an intent, we save the position on graph, otherwise we reset to root
        if(result.report[0].intent) { 
          last_jid = result.report[0].node.jid;
          last_title = result.report[0].title;
          last_intent = result.report[0].intent;
          console.log(last_jid, last_title, last_intent);
        } else last_jid = null;

        if((last_title == "Website Description")||(last_title == "Mobile Description")||(last_title == "IS Description")) { 
          meeting_msg();
          last_jid = "urn:uuid:3b7eae77-435e-489a-a8ae-570e43c2fc34";
          chat_messages.push(["bot", "Thank you! What else can we help you with?"]);
          update_messages();
        }
        if((last_title == "payment")) { 
          last_jid = "urn:uuid:3b7eae77-435e-489a-a8ae-570e43c2fc34";
          chat_messages.push(["bot", "Thank you! What else can we help you with?"]);
          update_messages();
        }

        //show the response message in the chat
      } 
      else {
        last_jid = null;
        chat_messages.push(["bot", "Hmm.. I don't understand what you mean."]);
        update_messages();
      }

    }).catch(function (error) {
        console.log(error);
    });
    update_messages();
}
function update_messages() {
    conv = "";
    for (let i = 0; i < chat_messages.length; i++) {
        if(chat_messages[i][0] == "bot"){
            new_message = '<p class="botText"><span>' + chat_messages[i][1] + '</span></p>';
        }
        else{
            new_message = '<p class="userText"><span>' + chat_messages[i][1] + '</span></p>';
        }
        // let userHtml = '<p class="userText"><span>' + chat_messages[i] + '</span></p>';
        // let botHtml = '<p class="botText"><span>' + chat_messages[i] + '</span></p>';
        conv = conv + new_message;
        // $("#chatbox").append(userHtml);
        // $("#chatbox").append(botHtml);
      }
      document.getElementById("chatbox").innerHTML = conv;
      document.getElementById("chat-bar-bottom").scrollIntoView(true);
      inputField.value = '';
}

function walker_run(name, utterance="", nd = null) {

    query = `
    {
      "name": "${name}",
      "ctx": {"utterance": "${utterance}"},
      "snt": "${sentinel_id}",
      "detailed":"false"
    }
    `;
  
    if(nd) { //if we have a node param
      query = `
      {
        "name": "${name}",
        "nd" : "${nd}",
        "ctx": {"utterance": "${utterance}"},
        "snt": "${sentinel_id}",
        "detailed":"false"
      }
      `;
    }
  
    return fetch(`${server}/js/walker_run`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `token ${token}`
      },
      body: query,
    }).then(function (result) {
      return result.json();
    });
  }