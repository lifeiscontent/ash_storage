defmodule AshArchival.Resource do
  @archive %Spark.Dsl.Section{
    name: :archive,
    describe: "A section for configuring how archival is configured for a resource.",
    schema: [
      attribute: [
        type: :atom,
        default: :archived_at,
        doc: "The attribute in which to store the archival flag (the current datetime)."
      ],
      base_filter?: [
        type: :atom,
        default: false,
        doc: "Whether or not a base filter exists that applies the `is_nil(archived_at)` rule."
      ],
      exclude_read_actions: [
        type: {:wrap_list, :atom},
        default: [],
        doc: """
        A read action or actions that should show archived items. They will not get the automatic `is_nil(archived_at)` filter.
        """
      ],
      exclude_destroy_actions: [
        type: {:wrap_list, :atom},
        default: [],
        doc: """
        A destroy action or actions that should *not* archive, but instead be left alone. This allows for having a destroy *or* archive pattern.
        """
      ],
      archive_related: [
        type: {:list, :atom},
        default: [],
        doc: """
        A list of relationships that should have all related items archived when this is archived. Notifications are not sent for this operation.
        """
      ]
    ]
  }

  @moduledoc """
  Configures a resource to be archived instead of destroyed for all destroy actions.

  For more information, see [the getting started guide](/documentation/tutorials/get-started-with-ash-archival.md)
  """

  use Spark.Dsl.Extension,
    sections: [@archive],
    transformers: [AshArchival.Resource.Transformers.SetupArchival]
end
