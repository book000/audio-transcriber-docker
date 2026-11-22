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
    "executablePath": "/usr/bin/google-chrome",
    "headless": false,
    "slowMo": 10,
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
const START_TIMEOUT_MS = 30000;
const FINALIZE_TIMEOUT_MS = 10000;
// Windows bind mounts reject ":" in file names, so replace every one.
const now = new Date().toISOString().replace(/:/g, "-");
puppeteer.launch(options).then(async browser => {
    try {
        console.log("Opened browser");
        const page = (await browser.pages())[0];
        console.log("Opened page");

        let start = Date.now();
        await page.exposeFunction("handleRecognized", async text => {
            console.log(text);
            try {
                await fs.promises.appendFile(`/opt/output/${now}.txt`, `[${toHHMMSS((Date.now() - start) / 1000)}] ${text}\n`);
            } catch (err) {
                console.error(err);
            }
        });
        await page.goto("https://book000.github.com/audio-transcriber", {
            waitUntil: [
                "load",
                "networkidle2"
            ]
        });

        // Runs in the browser context, where webkitSpeechRecognition and window.handleRecognized (exposed above) exist.
        // Resolves with null once recognition has started, or with an error message.
        const startError = await page.evaluate(startTimeoutMs => new Promise(resolve => {
            window.stopping = false;
            window.pending = new Set();
            window.resolveEnd = null;
            let ready = false;
            const fail = message => {
                // Prevent the onend restart loop after a failed start.
                window.stopping = true;
                clearTimeout(timer);
                resolve(message);
            };
            const timer = setTimeout(() => {
                fail(`Speech recognition did not start within ${startTimeoutMs} ms`);
            }, startTimeoutMs);
            function start_recognition() {
                const recognition = new webkitSpeechRecognition();
                window.recognition = recognition;
                recognition.continuous = true;
                recognition.lang = "ja";
                recognition.onresult = function (event) {
                    console.log(event);
                    for (var i = event.resultIndex; i < event.results.length; ++i) {
                        if (event.results[i].isFinal) {
                            const pending = window.handleRecognized(event.results[i][0].transcript);
                            window.pending.add(pending);
                            const done = () => window.pending.delete(pending);
                            pending.then(done, done);
                        } else {
                            console.log(event.results[i][0].transcript);
                        }
                    }
                };
                // Restart on every end event so recognition keeps running until finalization begins.
                recognition.onend = function (event) {
                    console.log("onend", event);
                    if (window.stopping) {
                        if (window.resolveEnd) {
                            window.resolveEnd();
                        }
                        return;
                    }
                    start_recognition();
                };
                recognition.onstart = function (event) {
                    console.log("onstart", event);
                    if (!ready) {
                        ready = true;
                        clearTimeout(timer);
                        resolve(null);
                    }
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
                    if (!ready && (event.error === "not-allowed" || event.error === "service-not-allowed")) {
                        fail(`Speech recognition failed to start: ${event.error}`);
                    }
                };
                recognition.start();
            }
            start_recognition();
        }), START_TIMEOUT_MS);
        if (startError) {
            throw new Error(startError);
        }
        console.log("Speech recognition ready");

        console.log("spawn paplay");
        start = Date.now();
        const playback = await new Promise(resolve => {
            const childProcess = spawn("paplay", ["--device=MicOutput", "-v", file]);
            childProcess.stdout.on("data", (data) => {
                console.log(data.toString());
            })
            childProcess.stderr.on("data", (data) => {
                process.stdout.write(data.toString());
            })
            childProcess.on("error", (err) => {
                resolve({ error: err });
            });
            childProcess.on("close", (code) => {
                console.log(code);
                resolve({ code });
            });
        });

        console.log("Stopping speech recognition");
        const ended = await page.evaluate(async finalizeTimeoutMs => {
            window.stopping = true;
            const ended = await new Promise(resolve => {
                const timer = setTimeout(() => {
                    window.resolveEnd = null;
                    resolve(false);
                }, finalizeTimeoutMs);
                // Registered before stop() so a synchronous onend is not missed.
                window.resolveEnd = () => {
                    clearTimeout(timer);
                    resolve(true);
                };
                window.recognition.stop();
            });
            await Promise.allSettled([...window.pending]);
            return ended;
        }, FINALIZE_TIMEOUT_MS);
        console.log(ended ? "Finalized speech recognition" : `Warning: speech recognition did not end within ${FINALIZE_TIMEOUT_MS} ms; closing the browser`);

        if (playback.error) {
            throw playback.error;
        }
    } catch (err) {
        console.error(err);
        process.exitCode = 1;
    } finally {
        await browser.close();
    }
    function toHHMMSS(sec) {
        var sec_num = parseInt(sec, 10);
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
});