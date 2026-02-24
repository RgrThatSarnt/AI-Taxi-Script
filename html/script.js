window.addEventListener("message", function(event) {
    if (event.data.action === "openConfirm") {
        document.getElementById("confirmBox").classList.remove("hidden");
    }
    if (event.data.action === "closeConfirm") {
        document.getElementById("confirmBox").classList.add("hidden");
    }
});

document.getElementById("confirm").onclick = function() {
    fetch(`https://${GetParentResourceName()}/confirm`, {
        method: "POST",
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({})
    });
};

document.getElementById("change").onclick = function() {
    fetch(`https://${GetParentResourceName()}/change`, {
        method: "POST",
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({})
    });
};
