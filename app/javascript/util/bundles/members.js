import React from "react";
import { render } from "react-dom";

import { camelizeKeys } from "../util/util";
import ComponentWrapper from "../components/ComponentWrapper";
import FundraiserView from "../containers/FundraiserView/FundraiserView";
import CallToolView from "../containers/CallToolView/CallToolView";
import EmailTargetView from "../containers/EmailTargetView/EmailTargetView";

import type { AppState } from "../state/reducers";

const store: Store<AppState, *> = window.champaignStore;

window.mountFundraiser = (root: string, initialState?: any = {}) => {
  store.dispatch({ type: "initialize_page", payload: window.champaign.page });
  store.dispatch({ type: "parse_champaign_data", payload: initialState });

  render(
    <ComponentWrapper store={store} locale={initialState["locale"]}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById(root)
  );

  if (process.env.NODE_ENV === "development" && module.hot) {
    module.hot.accept("../containers/FundraiserView/FundraiserView", () => {
      const UpdatedFundraiserView = require("../containers/FundraiserView/FundraiserView")
        .default;
      render(
        <ComponentWrapper store={store} locale={initialState["locale"]}>
          <UpdatedFundraiserView />
        </ComponentWrapper>,
        document.getElementById(root)
      );
    });
  }
};

window.mountCallTool = (root: string, props: any) => {
  props = camelizeKeys(props);

  render(
    <ComponentWrapper locale={props.locale}>
      <CallToolView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
