defmodule Shared.Auth.GameProofTest do
  use ExUnit.Case, async: true

  alias Shared.Auth.GameProof
  alias Shared.BinaryData

  describe "compute_digest/4" do
    test "computes SHA-1 of username || zero || client_seed || server_seed || session_key_le" do
      session_key = :binary.copy(<<0xAA>>, 40)
      username = "ADMIN"
      client_seed = 0x12345678
      server_seed = 0xABCDEF01

      result = GameProof.compute_digest(session_key, username, client_seed, server_seed)

      session_key_le = BinaryData.to_little_endian(session_key, 320)

      expected =
        :crypto.hash(:sha, [
          "ADMIN",
          <<0::unsigned-little-integer-size(32)>>,
          <<0x12345678::unsigned-little-integer-size(32)>>,
          <<0xABCDEF01::unsigned-little-integer-size(32)>>,
          session_key_le
        ])

      assert result == expected
      assert byte_size(result) == 20
    end

    test "uppercases the username before hashing" do
      session_key = :binary.copy(<<0xBB>>, 40)
      seed = 0x00000001

      upper = GameProof.compute_digest(session_key, "ADMIN", seed, seed)
      lower = GameProof.compute_digest(session_key, "admin", seed, seed)

      assert upper == lower
    end

    test "produces different digests for different seeds" do
      session_key = :binary.copy(<<0xCC>>, 40)

      digest_a = GameProof.compute_digest(session_key, "USER", 0x00000001, 0x00000001)
      digest_b = GameProof.compute_digest(session_key, "USER", 0x00000002, 0x00000001)

      refute digest_a == digest_b
    end

    test "produces different digests for different session keys" do
      key_a = :binary.copy(<<0xDD>>, 40)
      key_b = :binary.copy(<<0xEE>>, 40)

      digest_a = GameProof.compute_digest(key_a, "USER", 0x00000001, 0x00000001)
      digest_b = GameProof.compute_digest(key_b, "USER", 0x00000001, 0x00000001)

      refute digest_a == digest_b
    end
  end

  describe "verify?/5" do
    test "returns true when client proof matches expected digest" do
      session_key = :binary.copy(<<0xFF>>, 40)
      username = "TESTUSER"
      client_seed = 0xDEADBEEF
      server_seed = 0xCAFEBABE

      expected_digest = GameProof.compute_digest(session_key, username, client_seed, server_seed)

      assert GameProof.verify?(session_key, username, client_seed, server_seed, expected_digest)
    end

    test "returns false when client proof does not match" do
      session_key = :binary.copy(<<0xFF>>, 40)
      wrong_proof = :binary.copy(<<0x00>>, 20)

      refute GameProof.verify?(session_key, "USER", 0x01, 0x02, wrong_proof)
    end

    test "returns false for a proof that differs by a single byte" do
      session_key = :binary.copy(<<0xAB>>, 40)
      digest = GameProof.compute_digest(session_key, "USER", 0x01, 0x02)

      <<first::size(8), rest::binary>> = digest
      tampered = <<Bitwise.bxor(first, 0x01), rest::binary>>

      refute GameProof.verify?(session_key, "USER", 0x01, 0x02, tampered)
    end
  end
end
