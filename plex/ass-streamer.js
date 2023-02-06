// @refresh reset
import libjass from 'libjass';

export default class AssStreamer {
  ass = null;
  stream = null;
  xhrProxy = null;

  _pollDialogueTimerId = null;
  _dialoguesCount = 0;

  async start(xhrProxy, dialogueHandler) {
    this.cancel();

    try {
      this.xhrProxy = xhrProxy;
      const stream = new libjass.parser.XhrStream(xhrProxy);
      const streamParser = new libjass.parser.StreamParser(stream);

      streamParser.ass.catch(() => {}); // ignore error
      this.ass = await streamParser.minimalASS;

      this._cancelPollDialogue();
      this.pollDialogues(dialogueHandler);
    } catch (err) {
      console.error(err);
      this.cancel();
    }
  }

  pollDialogues(dialogueHandler) {
    // FIXME: polling is not very performent
    this._pollDialogueTimerId = setInterval(() => {
      if (!this.ass) return;

      if (this._dialoguesCount < this.ass.dialogues.length) {
        const dialogues = this.ass.dialogues.slice(this._dialoguesCount);
        dialogueHandler(dialogues.map(simplifyDialogue));

        this._dialoguesCount = this.ass.dialogues.length;
      }
    }, 50);
  }

  _cancelPollDialogue() {
    clearInterval(this._pollDialogueTimerId);
    this._pollDialogueTimerId = null;
    this._dialoguesCount = 0;
  }

  cancel() {
    if (this.ass) {
      if (this.stream) {
        this.stream.cancel();
        this.stream = null;
      }

      this._cancelPollDialogue();

      this.xhrProxy = null;
      this.ass = null;
      this.stream = null;
    }
  }
}

const simplifyDialogue = dialogue => {
  const text = dialogue.parts
    .filter(p => p instanceof libjass.parts.Text)
    .map(p => p.value)
    .join('');
  const start = Math.round(dialogue.start * 1000);
  const end = Math.round(dialogue.end * 1000);
  return {
    hash: `${start}${end}${text}`,
    data: {
      start,
      end,
      text,
    },
  };
};
