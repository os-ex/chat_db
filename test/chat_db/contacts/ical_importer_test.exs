defmodule ChatDB.Contacts.ICalImporterTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Support.Factory

  alias ChatDB.Config

  alias ChatDB.Contacts.ICalImporter

  @config Config.read()

  describe ".import_contacts/1" do
    test "with valid chat" do
      # assert ICalImporter.import_contacts(@config) == []
    end
  end

  describe ".cast_contacts/1" do
    test "with empty jcards" do
      jcards = []
      assert ICalImporter.cast_contacts(jcards) == []
    end

    test "with valid jcard without photo" do
      jcard = fixture(:jcard_no_photo)
      assert [contact] = ICalImporter.cast_contacts([jcard])
      assert contact == fixture(:contact_no_photo)
    end

    test "with valid jcard with photo" do
      jcard = fixture(:jcard_with_photo)

      assert [contact] = ICalImporter.cast_contacts([jcard])
      assert contact == fixture(:contact_with_photo)
    end

    # test "with valid jcards" do
    #   assert {:ok, jcards} = ICalImporter.read_json(@config.exported_jcards_filename)
    #   assert ICalImporter.cast_contacts(jcards) == []
    # end
  end

  describe ".separate_photos/1" do
    test "with valid contact without photo" do
      contact = fixture(:contact_no_photo)
      assert ICalImporter.separate_photos(contact) == {contact, []}
    end

    test "with valid contact with photo" do
      contact = fixture(:contact_with_photo)
      photo = fixture(:contact_photo)
      assert {contact, photos} = ICalImporter.separate_photos(contact)
      assert contact == fixture(:contact_without_photo)
      assert photos == [photo]
    end
  end

  describe ".persist/1" do
    test "with valid jcards" do
      # assert ICalImporter.persist(@config) == []
    end
  end

  describe ".transform/1" do
    test "with valid paths" do
      import_path = @config.exported_vcards_filename
      export_path = @config.exported_jcards_filename

      assert File.exists?(import_path)
      # File.rm_rf!(export_path)
      # refute File.exists?(export_path)
      assert ICalImporter.transform(import_path, export_path) == :ok
      assert File.exists?(export_path)
    end
  end

  describe ".read_json/1" do
    test "with valid path and json" do
      path = @config.exported_jcards_filename
      assert {:ok, _json} = ICalImporter.read_json(path)
    end

    test "with valid path but not valid json" do
      path = @config.exported_vcards_filename
      assert {:error, %Jason.DecodeError{}} = ICalImporter.read_json(path)
    end

    test "with invalid path" do
      path = "invalid"
      assert {:error, :enoent} = ICalImporter.read_json(path)
    end
  end
end
