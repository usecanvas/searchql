%{
  configs: [
    %{
      name: "default",
      files: %{included: ["lib/"]},
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.MaxLineLength, ignore_definitions: true, ignore_specs: true}
      ]
    }
  ]
}
