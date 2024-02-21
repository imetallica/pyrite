defmodule Realmd.Socket.Opcodes do
  @moduledoc """
  Binary values that represent the authentication codes.
  """

  def logon_challenge, do: 0x00
  def logon_proof, do: 0x01
  def reconnect_challenge, do: 0x02
  def reconnect_proof, do: 0x03
  def realmlist, do: 0x10

  # These are not used.
  def xfer_initiate, do: 0x30
  def xfer_data, do: 0x31
  def xfer_accept, do: 0x32
  def xfer_resume, do: 0x33
  def xfer_cancel, do: 0x34

  # Logon responses
  def logon_success, do: 0x00
  def logon_failed_unknown_1, do: 0x01
  def logon_failed_unknown_2, do: 0x02
  def logon_failed_banned, do: 0x03
  def logon_failed_unknown_account, do: 0x04
  def logon_failed_incorrect_password, do: 0x05
  def logon_failed_already_online, do: 0x06
  def logon_failed_no_time, do: 0x07
  def logon_failed_db_busy, do: 0x08
  def logon_failed_version_invalid, do: 0x09
  def logon_failed_version_update, do: 0x0A
  def logon_failed_invalid_server, do: 0x0B
  def logon_failed_suspended, do: 0x0C
  def logon_failed_no_access, do: 0x0D
  def logon_success_survey, do: 0x0E
  def logon_failed_parental_control, do: 0x0F
  def logon_failed_locked_enforced, do: 0x10
  def logon_failed_trial_expired, do: 0x11
  def logon_failed_use_bnet, do: 0x12
end
