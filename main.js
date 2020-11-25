let file = process.argv[2];
const fs = require("fs");
if (file == undefined) {
    file = "audio.wav";
}
if (!fs.existsSync(file)) {
    console.log("File not found: " + file);
    return;
}

const puppeteer = require("puppeteer");
const {
    spawn
} = require('child_process')
const options = {
    "executablePath": "google-chrome",
    "headless": false,
    "slowMo": 10,
    //"devtools": true,
    args: [
        "--no-sandbox",
        "--lang=ja-JP",
        "--user-data-dir=/opt/user-dir/",
        "--window-size=0,0",
        "--window-position=0,0"
    ],
    ignoreDefaultArgs: [
        "--mute-audio"
    ],
};
const now = new Date().toISOString().replace(/:/, "-");
puppeteer.launch(options).then(async browser => {
    console.log("Opened browser");
    const page = (await browser.pages())[0];
    console.log("Opened page");

    await page.exposeFunction("handleRecognized", text => {
        console.log(text);
        fs.appendFile(`/opt/output/${now}.txt`, `[${toHHMMSS((Date.now() - start) / 1000)}] ${text}\n`, (err) => {
            if (err) {
                console.error(err);
            }
        });
    });
    await page.goto("https://book000.github.com/audio-transcriber", {
        waitUntil: [
            "load",
            "networkidle2"
        ]
    });

    console.log("spawn paplay");
    const start = Date.now();
    const childProcess = spawn("paplay", ["--device=MicOutput", "-v", file]);
    childProcess.stdout.on("data", (data) => {
        console.log(data.toString());
    })
    childProcess.stderr.on("data", (data) => {
        process.stdout.write(data.toString());
    })
    childProcess.on("close", async (code) => {
        console.log(code);
        await browser.close();
    });

    await page.evaluate(async () => {
        function start_recognition() {
            recognition = new webkitSpeechRecognition();
            recognition.continuous = true;
            recognition.lang = "ja";
            recognition.onresult = function (event) {
                console.log(event);
                for (var i = event.resultIndex; i < event.results.length; ++i) {
                    if (event.results[i].isFinal) {
                        window.handleRecognized(event.results[i][0].transcript);
                    } else {
                        console.log(event.results[i][0].transcript);
                    }
                }
            };
            recognition.onend = function (event) {
                console.log("onend", event);
                return start_recognition();
            };
            recognition.onstart = function (event) {
                console.log("onstart", event);
            };
            recognition.onaudiostart = function (event) {
                console.log("onaudiostart", event);
            };
            recognition.onaudioend = function (event) {
                console.log("onaudioend", event);
            };
            recognition.onspeechstart = function (event) {
                console.log("onspeechstart", event);
            };
            recognition.onspeechend = function (event) {
                console.log("onspeechend", event);
            };
            recognition.onerror = function (event) {
                console.log("onerror", event);
            };
            recognition.start();
        }
        start_recognition();
    });
    function toHHMMSS(sec) {
        var sec_num = parseInt(sec, 10); // don't forget the second param
        var hours = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);

        if (hours < 10) {
            hours = "0" + hours;
        }
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        return hours + ':' + minutes + ':' + seconds;
    }
    //await browser.close();
});