const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


//THIS FUNCTION WORKS NOW!

exports.sendPushNotificationForClanInvitation = functions.database.ref('/users/{userId}/teamInvitations/{teamInvitationId}').onWrite(event => {

    const userId = event.params.userId;
    const teamInvitationId = event.params.teamInvitationId;
    
    const pathString = 'updates/teamInvitation/' + teamInvitationId;
    const teamInvitationUpdateRef = admin.database().ref(pathString).once('value')

    return teamInvitationUpdateRef.then(snapshot => {
        if (snapshot.val()) {
            const teamInvitationUpdate = snapshot.val();
            const teamname = teamInvitationUpdate.teamname;

            const fromId = teamInvitationUpdate.fromId;
            const fromUserRef = admin.database().ref(`users/${fromId}`).once('value')

            return fromUserRef.then(userSnap => {
                if (userSnap.val()) {
                    const fromUser = userSnap.val();
                    const fromName = fromUser.username;

                    const payload = {
                        notification: {
                            title: 'Clan Invitation',
                            body:  `${fromName} has invited you to join ${teamname}`,
                            badge: '1',
                            sound: 'default',
                        }
                    };

                    const tokenRef = admin.database().ref(`firebaseHelpers/fcmToken/${userId}`).once('value')

                    return tokenRef.then(tokenSnap => {
                        if (tokenSnap.val()) {
                            const tokenDictionary = tokenSnap.val();

                            const tokens = Object.keys(tokenDictionary);
                            return admin.messaging().sendToDevice(tokens, payload).then(response => {

                            });

                        };
                    });
                };
            });
        };
    });
});

//WORKS NOW TOO, PLEASE DONT TOUCH!

exports.clanMemberIsOnlineNotification = functions.database.ref('users/{userId}/isOnline').onWrite(event => {
    const currentUserId = event.params.userId;
    const onlineState = event.data.val();

    if (onlineState == true) {
        const currentUserPathString = 'users/' + currentUserId;
        const currentUserRef = admin.database().ref(currentUserPathString).once('value');


        return currentUserRef.then(userSnap => {
            if (userSnap.val()) {
                const dictionary = userSnap.val();
                if (teamId = dictionary.team) {
                    const currentUsername = dictionary.username;

                    const teamRef = admin.database().ref(`teams/${teamId}/member`).once('value');
                    return teamRef.then(teamSnapshot => {
                        const memberDictionary = teamSnapshot.val()
                        const memberArray = Object.keys(memberDictionary);

                        for (var i = 0, len = memberArray.length; i < len; i++) {
                            const userId = memberArray[i];
                            if (userId != currentUserId) {
                                const payload = {
                                    notification: {
                                        title: 'Clan Member is Online',
                                        body:  `${currentUsername} is currently online, play with him`,
                                        sound: 'default',
                                    }
                                };
            
                                const tokenRef = admin.database().ref(`firebaseHelpers/fcmToken/${userId}`).once('value')
            
                                return tokenRef.then(tokenSnap => {
                                    if (tokenSnap.val()) {
                                        const tokenDictionary = tokenSnap.val();
            
                                        const tokens = Object.keys(tokenDictionary);
                                        return admin.messaging().sendToDevice(tokens, payload).then(response => {

                                        });
                                    };
                                });
                            };
                        };
                    });
                };
            };
        });
    };
});

exports.sendMessageNotificationForSingleMessage = functions.database.ref('messages/{messageId}').onWrite(event => {
    const message = event.data.val()
    if (message.firebaseFunctionDone == true) {
        return
    }
    message.firebaseFunctionDone = true
    console.log('before setting')
    
    event.data.ref.set(message);

    const toId = message.toId
    const fromId = message.fromId
    const text = message.text

    console.log(toId, fromId, text)

    const fromUserRef = admin.database().ref(`users/${fromId}`).once('value')
    return fromUserRef.then(userSnap => {
        const userDictionary = userSnap.val()
        const fromUsername = userDictionary.username
        console.log('username ',fromUsername)

        const payload = {
            notification: {
                title: `${fromUsername}`,
                body:  `${text}`,
                sound: 'default',
            }
        };

        sendToken(toId, payload)

    });

});

function sendToken(userId, payload) {
    const tokenRef = admin.database().ref(`firebaseHelpers/fcmToken/${userId}`).once('value')
    
     return tokenRef.then(tokenSnap => {
        if (tokenSnap.val()) {
            const tokenDictionary = tokenSnap.val();
            console.log('tokenDictionary: ', tokenDictionary);
    
            const tokens = Object.keys(tokenDictionary);
            return admin.messaging().sendToDevice(tokens, payload).then(response => {
                console.log('sent payload');
            });
        };
    });
}



