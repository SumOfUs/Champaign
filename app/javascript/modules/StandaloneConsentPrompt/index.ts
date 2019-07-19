import { Petition } from '../../plugins/petition';

interface IConfig {
  el: HTMLElement;
  eventName: string;
  ref: string;
}

export const init = options => {
  return new StandaloneConsentPrompt(options);
};

export class StandaloneConsentPrompt {
  private petition?: Petition;

  constructor(public config: IConfig) {
    this.attachEventListeners();
  }

  public show() {
    this.config.el.classList.remove('hidden');
    this.config.el.scrollIntoView({
      behavior: 'smooth',
      block: 'start',
      inline: 'nearest',
    });
  }

  private hidePetition() {
    const parent = this.petitionParent();
    if (parent) {
      $(parent).fadeOut();
    }
  }

  private petitionParent() {
    if (!this.petition) {
      return;
    }
    if (!this.petition.el.dataset.transition) {
      return this.petition.el;
    }
    const transitionId = this.petition.el.dataset.transition.split(':')[0];
    return document.querySelector(`[data-transition-id="${transitionId}"]`);
  }

  private isConsentRequired() {
    if (!this.petition) {
      return false;
    }
    const { member, consent } = this.petition.store.getState();
    if (member && member.consented) {
      return false;
    }
    return consent.isRequiredNew;
  }

  private onValidated(petition: Petition) {
    this.petition = petition;
    if (this.isConsentRequired()) {
      this.hidePetition();
      this.show();
    } else {
      petition.submit();
    }
  }

  private attachEventListeners() {
    window.ee.on(this.config.eventName, (petition: Petition) =>
      this.onValidated(petition)
    );

    const optIn = this.config.el.querySelector('.button--opt-in');
    const optOut = this.config.el.querySelector('.button--opt-out');

    if (optIn) {
      optIn.addEventListener('click', () => {
        if (this.petition) {
          this.petition.updateForm({ consent: true });
          this.petition.submit();
        }
      });
    }

    if (optOut) {
      optOut.addEventListener('click', () => {
        if (this.petition) {
          this.petition.updateForm({ consent: false });
          this.petition.submit();
        }
      });
    }
  }
}
