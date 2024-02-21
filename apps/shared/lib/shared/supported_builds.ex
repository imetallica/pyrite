defmodule Shared.SupportedBuilds do
  defstruct [
    :build,
    :major_version,
    :minor_version,
    :bugfix_version,
    :hotfix_version,
    :windows_hash,
    :mac_hash
  ]

  @type t() :: %__MODULE__{
          build: integer(),
          major_version: integer(),
          minor_version: integer(),
          bugfix_version: integer(),
          hotfix_version: integer(),
          windows_hash: binary(),
          mac_hash: binary()
        }

  @spec versions() :: list(integer())
  def versions, do: Enum.map(the_versions(), & &1.build)

  defp the_versions,
    do: [
      %__MODULE__{
        # 1.12.3
        build: 6141,
        major_version: 1,
        minor_version: 12,
        bugfix_version: 3,
        hotfix_version: ?\s,
        windows_hash:
          <<0xEB, 0x88, 0x24, 0x3E, 0x94, 0x26, 0xC9, 0xD6, 0x8C, 0x81, 0x87, 0xF7, 0xDA, 0xE2,
            0x25, 0xEA, 0xF3, 0x88, 0xD8, 0xAF>>,
        mac_hash: <<>>
      },
      %__MODULE__{
        # 1.12.2
        build: 6005,
        major_version: 1,
        minor_version: 12,
        bugfix_version: 2,
        hotfix_version: ?\s,
        windows_hash:
          <<0x06, 0x97, 0x32, 0x38, 0x76, 0x56, 0x96, 0x41, 0x48, 0x79, 0x28, 0xFD, 0xC7, 0xC9,
            0xE3, 0x3B, 0x44, 0x70, 0xC8, 0x80>>,
        mac_hash: <<>>
      },
      %__MODULE__{
        # 1.12.1
        build: 5875,
        major_version: 1,
        minor_version: 12,
        bugfix_version: 1,
        hotfix_version: ?\s,
        windows_hash:
          <<0x95, 0xED, 0xB2, 0x7C, 0x78, 0x23, 0xB3, 0x63, 0xCB, 0xDD, 0xAB, 0x56, 0xA3, 0x92,
            0xE7, 0xCB, 0x73, 0xFC, 0xCA, 0x20>>,
        mac_hash:
          <<0x8D, 0x17, 0x3C, 0xC3, 0x81, 0x96, 0x1E, 0xEB, 0xAB, 0xF3, 0x36, 0xF5, 0xE6, 0x67,
            0x5B, 0x10, 0x1B, 0xB5, 0x13, 0xE5>>
      }
    ]
end
