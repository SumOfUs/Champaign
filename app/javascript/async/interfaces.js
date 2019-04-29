// @flow

export interface PluginConfig {
  ref: string;
  active: boolean;
  locale: string;
  pageId: number;
  pluginId: number;
  title: string;
}

export interface EmailPluginConfig extends PluginConfig {
  subject: string;
  template: string;
}
