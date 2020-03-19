function createButton() {
    var button = document.createElement("button");
    button.id = "countButton";
    button.innerHTML = "Count";
    document.getElementById("container").appendChild(button);
    button.addEventListener('click', function(){
                            window.webkit.messageHandlers.count.postMessage("You've clicked");
                            });
}

function creatCountLabel() {
    var label = document.createElement("label");
    label.id = "countLabel";
    label.innerHTML = "Count: 0";
    document.getElementById("container").appendChild(label);
}

createButton();
creatCountLabel();
