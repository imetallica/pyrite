defmodule Shared.Data.Base.BasePlayer.RaceStats do
  @moduledoc """
  This module represents the stats of a player
  in the emulator.
  """
  alias Shared.Data.Dbc.ChrRaces
  alias Shared.Data.Dbc.ChrClasses
  use Ecto.Schema

  @type t() :: %__MODULE__{
          str: non_neg_integer,
          agi: non_neg_integer,
          sta: non_neg_integer,
          int: non_neg_integer,
          spi: non_neg_integer
        }

  @primary_key false
  embedded_schema do
    field(:str, :integer, default: 0)
    field(:agi, :integer, default: 0)
    field(:sta, :integer, default: 0)
    field(:int, :integer, default: 0)
    field(:spi, :integer, default: 0)
  end

  @spec new(level :: non_neg_integer(), race :: ChrRaces.t(), class :: ChrClasses.t()) :: t()

  @human ChrRaces.human()
  @warrior ChrClasses.warrior()
  @paladin ChrClasses.paladin()

  @spec new(1..60, ChrRaces.t(), ChrClasses.t()) :: t()
  def new(01, @human, @warrior), do: %__MODULE__{str: 23, agi: 20, sta: 22, int: 20, spi: 21}
  def new(02, @human, @warrior), do: %__MODULE__{str: 24, agi: 21, sta: 23, int: 20, spi: 21}
  def new(03, @human, @warrior), do: %__MODULE__{str: 25, agi: 21, sta: 24, int: 20, spi: 22}
  def new(04, @human, @warrior), do: %__MODULE__{str: 26, agi: 22, sta: 25, int: 20, spi: 22}
  def new(05, @human, @warrior), do: %__MODULE__{str: 28, agi: 23, sta: 26, int: 20, spi: 22}
  def new(06, @human, @warrior), do: %__MODULE__{str: 29, agi: 24, sta: 27, int: 21, spi: 22}
  def new(07, @human, @warrior), do: %__MODULE__{str: 30, agi: 24, sta: 28, int: 21, spi: 23}
  def new(08, @human, @warrior), do: %__MODULE__{str: 31, agi: 25, sta: 29, int: 21, spi: 23}
  def new(09, @human, @warrior), do: %__MODULE__{str: 32, agi: 26, sta: 30, int: 21, spi: 23}
  def new(10, @human, @warrior), do: %__MODULE__{str: 33, agi: 26, sta: 31, int: 21, spi: 24}
  def new(11, @human, @warrior), do: %__MODULE__{str: 35, agi: 27, sta: 33, int: 21, spi: 24}
  def new(12, @human, @warrior), do: %__MODULE__{str: 36, agi: 28, sta: 34, int: 21, spi: 24}
  def new(13, @human, @warrior), do: %__MODULE__{str: 37, agi: 29, sta: 35, int: 21, spi: 25}
  def new(14, @human, @warrior), do: %__MODULE__{str: 39, agi: 30, sta: 36, int: 22, spi: 25}
  def new(15, @human, @warrior), do: %__MODULE__{str: 40, agi: 30, sta: 37, int: 22, spi: 25}
  def new(16, @human, @warrior), do: %__MODULE__{str: 41, agi: 31, sta: 38, int: 22, spi: 26}
  def new(17, @human, @warrior), do: %__MODULE__{str: 42, agi: 32, sta: 40, int: 22, spi: 26}
  def new(18, @human, @warrior), do: %__MODULE__{str: 44, agi: 33, sta: 41, int: 22, spi: 26}
  def new(19, @human, @warrior), do: %__MODULE__{str: 44, agi: 33, sta: 41, int: 22, spi: 26}
  def new(20, @human, @warrior), do: %__MODULE__{str: 47, agi: 35, sta: 43, int: 22, spi: 27}
  def new(21, @human, @warrior), do: %__MODULE__{str: 48, agi: 35, sta: 45, int: 23, spi: 27}
  def new(22, @human, @warrior), do: %__MODULE__{str: 49, agi: 36, sta: 46, int: 23, spi: 28}
  def new(23, @human, @warrior), do: %__MODULE__{str: 51, agi: 37, sta: 47, int: 23, spi: 28}
  def new(24, @human, @warrior), do: %__MODULE__{str: 52, agi: 38, sta: 49, int: 23, spi: 29}
  def new(25, @human, @warrior), do: %__MODULE__{str: 54, agi: 39, sta: 50, int: 23, spi: 29}
  def new(26, @human, @warrior), do: %__MODULE__{str: 55, agi: 40, sta: 51, int: 23, spi: 29}
  def new(27, @human, @warrior), do: %__MODULE__{str: 57, agi: 41, sta: 53, int: 23, spi: 30}
  def new(28, @human, @warrior), do: %__MODULE__{str: 58, agi: 42, sta: 54, int: 24, spi: 30}
  def new(29, @human, @warrior), do: %__MODULE__{str: 60, agi: 43, sta: 56, int: 24, spi: 31}
  def new(30, @human, @warrior), do: %__MODULE__{str: 62, agi: 44, sta: 57, int: 24, spi: 31}
  def new(31, @human, @warrior), do: %__MODULE__{str: 63, agi: 45, sta: 58, int: 24, spi: 31}
  def new(32, @human, @warrior), do: %__MODULE__{str: 65, agi: 46, sta: 60, int: 24, spi: 32}
  def new(33, @human, @warrior), do: %__MODULE__{str: 66, agi: 47, sta: 61, int: 24, spi: 32}
  def new(34, @human, @warrior), do: %__MODULE__{str: 68, agi: 48, sta: 63, int: 25, spi: 33}
  def new(35, @human, @warrior), do: %__MODULE__{str: 70, agi: 49, sta: 64, int: 25, spi: 33}
  def new(36, @human, @warrior), do: %__MODULE__{str: 72, agi: 50, sta: 66, int: 25, spi: 34}
  def new(37, @human, @warrior), do: %__MODULE__{str: 73, agi: 51, sta: 68, int: 25, spi: 34}
  def new(38, @human, @warrior), do: %__MODULE__{str: 75, agi: 52, sta: 69, int: 25, spi: 34}
  def new(39, @human, @warrior), do: %__MODULE__{str: 77, agi: 53, sta: 71, int: 26, spi: 35}
  def new(40, @human, @warrior), do: %__MODULE__{str: 79, agi: 54, sta: 72, int: 26, spi: 35}
  def new(41, @human, @warrior), do: %__MODULE__{str: 80, agi: 56, sta: 74, int: 26, spi: 36}
  def new(42, @human, @warrior), do: %__MODULE__{str: 82, agi: 57, sta: 76, int: 26, spi: 36}
  def new(43, @human, @warrior), do: %__MODULE__{str: 84, agi: 58, sta: 77, int: 26, spi: 37}
  def new(44, @human, @warrior), do: %__MODULE__{str: 86, agi: 59, sta: 79, int: 26, spi: 37}
  def new(45, @human, @warrior), do: %__MODULE__{str: 88, agi: 60, sta: 81, int: 27, spi: 38}
  def new(46, @human, @warrior), do: %__MODULE__{str: 90, agi: 61, sta: 83, int: 27, spi: 38}
  def new(47, @human, @warrior), do: %__MODULE__{str: 92, agi: 63, sta: 84, int: 27, spi: 39}
  def new(48, @human, @warrior), do: %__MODULE__{str: 94, agi: 64, sta: 86, int: 27, spi: 39}
  def new(49, @human, @warrior), do: %__MODULE__{str: 96, agi: 65, sta: 88, int: 28, spi: 40}
  def new(50, @human, @warrior), do: %__MODULE__{str: 98, agi: 66, sta: 90, int: 28, spi: 40}
  def new(51, @human, @warrior), do: %__MODULE__{str: 100, agi: 68, sta: 92, int: 28, spi: 42}
  def new(52, @human, @warrior), do: %__MODULE__{str: 102, agi: 69, sta: 94, int: 28, spi: 42}
  def new(53, @human, @warrior), do: %__MODULE__{str: 104, agi: 70, sta: 96, int: 28, spi: 43}
  def new(54, @human, @warrior), do: %__MODULE__{str: 106, agi: 72, sta: 98, int: 29, spi: 44}
  def new(55, @human, @warrior), do: %__MODULE__{str: 109, agi: 73, sta: 100, int: 29, spi: 44}
  def new(56, @human, @warrior), do: %__MODULE__{str: 111, agi: 74, sta: 102, int: 29, spi: 45}
  def new(57, @human, @warrior), do: %__MODULE__{str: 113, agi: 76, sta: 104, int: 29, spi: 45}
  def new(58, @human, @warrior), do: %__MODULE__{str: 115, agi: 77, sta: 106, int: 30, spi: 46}
  def new(59, @human, @warrior), do: %__MODULE__{str: 118, agi: 79, sta: 108, int: 30, spi: 46}
  def new(60, @human, @warrior), do: %__MODULE__{str: 120, agi: 80, sta: 110, int: 30, spi: 47}

  # def new(01, @human, @paladin), do: %__MODULE__{str: , agi: 20, sta: 22, int: 20, spi: 21}
  # def new(02, @human, @paladin), do: %__MODULE__{str: , agi: 21, sta: 23, int: 20, spi: 21}
  # def new(03, @human, @paladin), do: %__MODULE__{str: , agi: 21, sta: 24, int: 20, spi: 22}
  # def new(04, @human, @paladin), do: %__MODULE__{str: , agi: 22, sta: 25, int: 20, spi: 22}
  # def new(05, @human, @paladin), do: %__MODULE__{str: , agi: 23, sta: 26, int: 20, spi: 22}
  # def new(06, @human, @paladin), do: %__MODULE__{str: , agi: 24, sta: 27, int: 21, spi: 22}
  # def new(07, @human, @paladin), do: %__MODULE__{str: , agi: 24, sta: 28, int: 21, spi: 23}
  # def new(08, @human, @paladin), do: %__MODULE__{str: , agi: 25, sta: 29, int: 21, spi: 23}
  # def new(09, @human, @paladin), do: %__MODULE__{str: , agi: 26, sta: 30, int: 21, spi: 23}
  # def new(10, @human, @paladin), do: %__MODULE__{str: , agi: 26, sta: 31, int: 21, spi: 24}
  # def new(11, @human, @paladin), do: %__MODULE__{str: 35, agi: 27, sta: 33, int: 21, spi: 24}
  # def new(12, @human, @paladin), do: %__MODULE__{str: 36, agi: 28, sta: 34, int: 21, spi: 24}
  # def new(13, @human, @paladin), do: %__MODULE__{str: 37, agi: 29, sta: 35, int: 21, spi: 25}
  # def new(14, @human, @paladin), do: %__MODULE__{str: 39, agi: 30, sta: 36, int: 22, spi: 25}
  # def new(15, @human, @paladin), do: %__MODULE__{str: 40, agi: 30, sta: 37, int: 22, spi: 25}
  # def new(16, @human, @paladin), do: %__MODULE__{str: 41, agi: 31, sta: 38, int: 22, spi: 26}
  # def new(17, @human, @paladin), do: %__MODULE__{str: 42, agi: 32, sta: 40, int: 22, spi: 26}
  # def new(18, @human, @paladin), do: %__MODULE__{str: 44, agi: 33, sta: 41, int: 22, spi: 26}
  # def new(19, @human, @paladin), do: %__MODULE__{str: 44, agi: 33, sta: 41, int: 22, spi: 26}
  # def new(20, @human, @paladin), do: %__MODULE__{str: 47, agi: 35, sta: 43, int: 22, spi: 27}
  # def new(21, @human, @paladin), do: %__MODULE__{str: 48, agi: 35, sta: 45, int: 23, spi: 27}
  # def new(22, @human, @paladin), do: %__MODULE__{str: 49, agi: 36, sta: 46, int: 23, spi: 28}
  # def new(23, @human, @paladin), do: %__MODULE__{str: 51, agi: 37, sta: 47, int: 23, spi: 28}
  # def new(24, @human, @paladin), do: %__MODULE__{str: 52, agi: 38, sta: 49, int: 23, spi: 29}
  # def new(25, @human, @paladin), do: %__MODULE__{str: 54, agi: 39, sta: 50, int: 23, spi: 29}
  # def new(26, @human, @paladin), do: %__MODULE__{str: 55, agi: 40, sta: 51, int: 23, spi: 29}
  # def new(27, @human, @paladin), do: %__MODULE__{str: 57, agi: 41, sta: 53, int: 23, spi: 30}
  # def new(28, @human, @paladin), do: %__MODULE__{str: 58, agi: 42, sta: 54, int: 24, spi: 30}
  # def new(29, @human, @paladin), do: %__MODULE__{str: 60, agi: 43, sta: 56, int: 24, spi: 31}
  # def new(30, @human, @paladin), do: %__MODULE__{str: 62, agi: 44, sta: 57, int: 24, spi: 31}
  # def new(31, @human, @paladin), do: %__MODULE__{str: 63, agi: 45, sta: 58, int: 24, spi: 31}
  # def new(32, @human, @paladin), do: %__MODULE__{str: 65, agi: 46, sta: 60, int: 24, spi: 32}
  # def new(33, @human, @paladin), do: %__MODULE__{str: 66, agi: 47, sta: 61, int: 24, spi: 32}
  # def new(34, @human, @paladin), do: %__MODULE__{str: 68, agi: 48, sta: 63, int: 25, spi: 33}
  # def new(35, @human, @paladin), do: %__MODULE__{str: 70, agi: 49, sta: 64, int: 25, spi: 33}
  # def new(36, @human, @paladin), do: %__MODULE__{str: 72, agi: 50, sta: 66, int: 25, spi: 34}
  # def new(37, @human, @paladin), do: %__MODULE__{str: 73, agi: 51, sta: 68, int: 25, spi: 34}
  # def new(38, @human, @paladin), do: %__MODULE__{str: 75, agi: 52, sta: 69, int: 25, spi: 34}
  # def new(39, @human, @paladin), do: %__MODULE__{str: 77, agi: 53, sta: 71, int: 26, spi: 35}
  # def new(40, @human, @paladin), do: %__MODULE__{str: 79, agi: 54, sta: 72, int: 26, spi: 35}
  # def new(41, @human, @paladin), do: %__MODULE__{str: 80, agi: 56, sta: 74, int: 26, spi: 36}
  # def new(42, @human, @paladin), do: %__MODULE__{str: 82, agi: 57, sta: 76, int: 26, spi: 36}
  # def new(43, @human, @paladin), do: %__MODULE__{str: 84, agi: 58, sta: 77, int: 26, spi: 37}
  # def new(44, @human, @paladin), do: %__MODULE__{str: 86, agi: 59, sta: 79, int: 26, spi: 37}
  # def new(45, @human, @paladin), do: %__MODULE__{str: 88, agi: 60, sta: 81, int: 27, spi: 38}
  # def new(46, @human, @paladin), do: %__MODULE__{str: 90, agi: 61, sta: 83, int: 27, spi: 38}
  # def new(47, @human, @paladin), do: %__MODULE__{str: 92, agi: 63, sta: 84, int: 27, spi: 39}
  # def new(48, @human, @paladin), do: %__MODULE__{str: 94, agi: 64, sta: 86, int: 27, spi: 39}
  # def new(49, @human, @paladin), do: %__MODULE__{str: 96, agi: 65, sta: 88, int: 28, spi: 40}
  # def new(50, @human, @paladin), do: %__MODULE__{str: 98, agi: 66, sta: 90, int: 28, spi: 40}
  # def new(51, @human, @paladin), do: %__MODULE__{str: 100, agi: 68, sta: 92, int: 28, spi: 42}
  # def new(52, @human, @paladin), do: %__MODULE__{str: 102, agi: 69, sta: 94, int: 28, spi: 42}
  # def new(53, @human, @paladin), do: %__MODULE__{str: 104, agi: 70, sta: 96, int: 28, spi: 43}
  # def new(54, @human, @paladin), do: %__MODULE__{str: 106, agi: 72, sta: 98, int: 29, spi: 44}
  # def new(55, @human, @paladin), do: %__MODULE__{str: 109, agi: 73, sta: 100, int: 29, spi: 44}
  # def new(56, @human, @paladin), do: %__MODULE__{str: 111, agi: 74, sta: 102, int: 29, spi: 45}
  # def new(57, @human, @paladin), do: %__MODULE__{str: 113, agi: 76, sta: 104, int: 29, spi: 45}
  # def new(58, @human, @paladin), do: %__MODULE__{str: 115, agi: 77, sta: 106, int: 30, spi: 46}
  # def new(59, @human, @paladin), do: %__MODULE__{str: 118, agi: 79, sta: 108, int: 30, spi: 46}
  # def new(60, @human, @paladin), do: %__MODULE__{str: 120, agi: 80, sta: 110, int: 30, spi: 47}
end
