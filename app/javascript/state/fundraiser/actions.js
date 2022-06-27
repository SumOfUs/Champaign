import ee from '../../shared/pub_sub';

export function changeAmount(payload) {
  ee.emit('fundraiser:change_amount', payload);
  return { type: 'change_amount', payload, skip_log: true };
}

export function oneClickFailed() {
  return { type: 'one_click_failed' };
}

export function changeCurrency(payload) {
  ee.emit('fundraiser:change_currency', payload);
  return { type: 'change_currency', payload, skip_log: true };
}

export function setSubmitting(payload) {
  return { type: 'set_submitting', payload };
}

export function changeStep(payload) {
  // we put it in a timeout because otherwise the event is fired before the step has switched
  setTimeout(() => ee.emit('fundraiser:change_step', payload), 100);
  return { type: 'change_step', payload };
}

export function setIsCustomAmount(payload, amount) {
  return (dispatch, getState) => {
    if (payload) {
      const state = getState();
      const { selectedAmountButton, donationAmount } = state.fundraiser;

      const event =
        selectedAmountButton && donationAmount === null
          ? 'form:select_amount'
          : 'change_amount';
      const getGaLabel = (selectedButton, amount, otherAmount) => {
        if (amount && selectedButton === null) {
          return `from_url_${amount}_to_field_other_${otherAmount}`;
        }
        return selectedButton === null
          ? `field_other_${otherAmount}`
          : `from_button_${selectedButton}_to_field_other_${otherAmount}`;
      };

      const label = getGaLabel(selectedAmountButton, donationAmount, amount);

      ee.emit(event, { label, amount: null });
    }

    dispatch({ type: 'set_is_custom_amount', payload });
  };
}

export function setSelectedAmountButton(payload) {
  return (dispatch, getState) => {
    const state = getState();
    const { selectedAmountButton, donationAmount, isCustomAmount } =
      state.fundraiser || {};
    console.log(selectedAmountButton, donationAmount, isCustomAmount);
    const event =
      !selectedAmountButton && !donationAmount
        ? 'form:select_amount'
        : 'change_amount';
    const getGaLabel = (selectedButton, amount, isCustom) => {
      if (amount && selectedButton === null && !isCustom) {
        return `from_url_${amount}_to_button_${payload}`;
      } else if (amount && isCustom) {
        return `from_field_other_${amount}_to_button_${payload}`;
      }

      return selectedButton === null
        ? `button_${payload}`
        : `from_button_${selectedButton}_to_button_${payload}`;
    };

    const label = getGaLabel(
      selectedAmountButton,
      donationAmount,
      isCustomAmount
    );

    ee.emit(event, { label, amount: null });

    dispatch({ type: 'set_selected_amount_button', payload });
  };
}

export function updateForm(payload) {
  return { type: 'update_form', payload };
}

export function setRecurring(payload = false) {
  setTimeout(() => ee.emit('fundraiser:change_recurring', payload), 100);
  return { type: 'set_recurring', payload };
}

export function setStoreInVault(payload = false) {
  const storeInVaultChoice = payload ? 'checked' : 'unchecked';
  const label = `user_${storeInVaultChoice}_to_store_payment_info`;
  setTimeout(() => ee.emit('fundraiser:set_store_in_vault', label), 100);
  return { type: 'set_store_in_vault', payload, skip_log: true };
}

export function setPaymentType(payload) {
  return { type: 'set_payment_type', payload, skip_log: true };
}

export function actionFormUpdated(data) {
  return { type: '@@chmp:action_form:updated', payload: data };
}

export function setSupportedLocalCurrency(payload) {
  return { type: 'set_supported_local_currency', payload };
}
