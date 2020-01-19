import { Elm } from "./Main.elm";

const basePath = new URL(document.baseURI).pathname;
Elm.Main.init({
  flags: {
    basePath: basePath
  },
  node: document.querySelector("main")
});
