## VoxImplant platform demo
1. Following [the doc](https://voximplant.com/docs/tutorials/recording/video-recording) create simple scenario on VoxImplant platform and add user
2. Add this code into scenario

        VoxEngine.addEventListener(AppEvents.CallAlerting, (e) => {
            e.call.addEventListener(CallEvents.Connected, handleCallConnected);
            e.call.addEventListener(CallEvents.RecordStarted, handleRecordStarted);
            e.call.addEventListener(CallEvents.Failed, VoxEngine.terminate);
            e.call.addEventListener(CallEvents.Disconnected, VoxEngine.terminate);
            e.call.answer();
        });

        function handleCallConnected(e) {
            // Record call including video
            e.call.record({video:true});
        }

        function handleRecordStarted(e) {
            // Send video URL to client
            e.call.sendMessage(JSON.stringify({url: e.url}));
        }
3. Run your favorite emulator with `flutter emulators --launch`
4. Create .env file in root folder with content

        USER=USERNAME@YOUR_APP_URL
        PASSWORD=ACTUAL_PASSWORD
5. `flutter run`
