export const SET_VARIANT = 'SET_VARIANT';

const initialState = {
  experiments: [],
};

export default (state = initialState, action) => {
  switch (action.type) {
    case 'SET_VARIANT':
      const { variant, experimentId } = action.payload;
      if (!variant || !experimentId) return initialState;
      return {
        ...state,
        experiments: [...state.experiments, action.payload],
      };
    default:
      return state;
  }
};

export function setExperimentVariant(payload) {
  return { type: 'SET_VARIANT', payload };
}
