// @refresh reset
import libjass from 'libjass';

export default class AssStreamer {
  ass = null;
  id = null;
  stream = null;

  _pollDialogueTimerId = null;
  _dialoguesCount = 0;

  async start(ratingKey, xhrProxy, dialogueHandler) {
    this.cancel();

    try {
      const stream = new libjass.parser.XhrStream(xhrProxy);
      const streamParser = new libjass.parser.StreamParser(stream);

      this.ass = await streamParser.minimalASS;
      this.id = ratingKey;

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

      this.ass = null;
      this.id = null;
      this.stream = null;
    }
  }
}

const simplifyDialogue = dialogue => {
  return {
    id: dialogue.id,
    start: Math.round(dialogue.start * 1000),
    end: Math.round(dialogue.end * 1000),
    text: dialogue.parts
      .filter(p => p instanceof libjass.parts.Text)
      .map(p => p.value)
      .join(''),
  };
};
