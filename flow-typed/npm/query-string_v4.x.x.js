// flow-typed signature: d7aa81f9489bb4260dfbb73717f500b0
// flow-typed version: <<STUB>>/query-string_v4.3/flow_v0.48.0

declare module 'query-string' {
  declare type ParseOptions = {
    arrayFormat?: 'bracket' | 'index' | 'none',
  };

  declare type StringifyOptions = {
    strict?: boolean,
    encode?: boolean,
    arrayFormat?: 'bracket' | 'index' | 'none',
  };

  declare function parse(
    str: string,
    opts?: ParseOptions
  ): { [key: string]: string };

  declare function stringify(obj: Object, opts?: StringifyOptions): string;
  declare function extract(str: string): string;
}
