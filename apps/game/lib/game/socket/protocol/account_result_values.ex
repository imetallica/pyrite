defmodule Game.Socket.Protocol.AccountResultValues do
  @moduledoc """
  Result values used by Game Packets during authentication, character creation and login.
  """
  # RESPONSE
  def response_success, do: 0x00
  def response_failure, do: 0x01
  def response_cancelled, do: 0x02
  def response_disconnected, do: 0x03
  def response_failed_to_connect, do: 0x04
  def response_connected, do: 0x05
  def response_version_mismatch, do: 0x06

  # CSTATUS
  def cstatus_connecting, do: 0x07
  def cstatus_negotiating_security, do: 0x08
  def cstatus_negotiation_complete, do: 0x09
  def cstatus_negotiation_failed, do: 0x0A
  def cstatus_authenticating, do: 0x0B

  # AUTH
  def auth_ok, do: 0x0C
  def auth_failed, do: 0x0D
  def auth_reject, do: 0x0E
  def auth_bad_server_proof, do: 0x0F
  def auth_unavailable, do: 0x10
  def auth_system_error, do: 0x11
  def auth_billing_error, do: 0x12
  def auth_billing_expired, do: 0x13
  def auth_version_mismatch, do: 0x14
  def auth_unknown_account, do: 0x15
  def auth_incorrect_password, do: 0x16
  def auth_session_expired, do: 0x17
  def auth_server_shutting_down, do: 0x18
  def auth_already_logging_in, do: 0x19
  def auth_login_server_not_found, do: 0x1A
  def auth_wait_queue, do: 0x1B
  def auth_banned, do: 0x1C
  def auth_already_online, do: 0x1D
  def auth_no_time, do: 0x1E
  def auth_db_busy, do: 0x1F
  def auth_suspended, do: 0x20
  def auth_parental_control, do: 0x21

  # REALM LIST
  def realm_list_in_progress, do: 0x22
  def realm_list_success, do: 0x23
  def realm_list_failed, do: 0x24
  def realm_list_invalid, do: 0x25
  def realm_list_realm_not_found, do: 0x26

  # ACCOUNT CREATE
  def account_create_in_progress, do: 0x27
  def account_create_success, do: 0x28
  def account_create_failed, do: 0x29

  # CHAR LIST
  def char_list_retrieving, do: 0x2A
  def char_list_retrieved, do: 0x2B
  def char_list_failed, do: 0x2C

  # CHAR CREATE
  def char_create_in_progress, do: 0x2D
  def char_create_success, do: 0x2E
  def char_create_error, do: 0x2F
  def char_create_failed, do: 0x30
  def char_create_name_in_use, do: 0x31
  def char_create_disabled, do: 0x32
  def char_create_pvp_teams_violation, do: 0x33
  def char_create_server_limit, do: 0x34
  def char_create_account_limit, do: 0x35
  def char_create_server_queue, do: 0x36
  def char_create_only_existing, do: 0x37

  # CHAR DELETE
  def char_delete_in_progress, do: 0x38
  def char_delete_success, do: 0x39
  def char_delete_failed, do: 0x3A
  def char_delete_failed_locked_for_transfer, do: 0x3B

  # CHAR LOGIN
  def char_login_in_progress, do: 0x3C
  def char_login_success, do: 0x3D
  def char_login_no_Game, do: 0x3E
  def char_login_duplicate_character, do: 0x3F
  def char_login_no_instances, do: 0x40
  def char_login_failed, do: 0x41
  def char_login_disabled, do: 0x42
  def char_login_no_character, do: 0x43
  def char_login_locked_for_transfer, do: 0x44

  # CHAR NAME
  def char_name_no_name, do: 0x45
  def char_name_too_short, do: 0x46
  def char_name_too_long, do: 0x47
  def char_name_only_letters, do: 0x48
  def char_name_mixed_languages, do: 0x49
  def char_name_profane, do: 0x4A
  def char_name_reserved, do: 0x4B
  def char_name_invalid_apostrophe, do: 0x4C
  def char_name_multiple_apostrophes, do: 0x4D
  def char_name_three_consecutive, do: 0x4E
  def char_name_invalid_space, do: 0x4F
  def char_name_success, do: 0x50
  def char_name_failure, do: 0x51
end
