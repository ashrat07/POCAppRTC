function createButton() {
    var button = document.createElement("button");
    button.id = "takeSnapshotButton";
    button.innerHTML = "Take Snapshot (From Native)";
    var canvas = document.querySelector("canvas");
    if (canvas) {
        canvas.parentNode.insertBefore(button, canvas);
    }
    else {
        document.getElementById("container").appendChild(button);
    }
    button.addEventListener('click', function() {
        takeSnapshot();
    });
}

function insertAfter(el, referenceNode) {
    referenceNode.parentNode.insertBefore(el, referenceNode.nextSibling);
}

function takeSnapshot() {
    var key = Object.keys(iosrtc.mediaStreamRenderers)[0];
    iosrtc.mediaStreamRenderers[key].save(function(data) {
        var image = new Image();
        image.src = data;
        image.onload = function() {
            var canvas = document.querySelector("canvas");
            canvas.width = image.width;
            canvas.height = image.height;
            canvas.getContext('2d').drawImage(this, 0, 0, canvas.width, canvas.height);
        };
    });
}

createButton();
