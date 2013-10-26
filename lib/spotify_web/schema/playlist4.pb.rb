## Generated from playlist4.proto for spotify.playlist4.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Playlist4

      module ListAttributeKind
        LIST_UNKNOWN = 0
        LIST_NAME = 1
        LIST_DESCRIPTION = 2
        LIST_PICTURE = 3
        LIST_COLLABORATIVE = 4
        LIST_PL3_VERSION = 5
        LIST_DELETED_BY_OWNER = 6
        LIST_RESTRICTED_COLLABORATIVE = 7
      end

      module ItemAttributeKind
        ITEM_UNKNOWN = 0
        ITEM_ADDED_BY = 1
        ITEM_TIMESTAMP = 2
        ITEM_MESSAGE = 3
        ITEM_SEEN = 4
        ITEM_DOWNLOAD_COUNT = 5
        ITEM_DOWNLOAD_FORMAT = 6
        ITEM_SEVENDIGITAL_ID = 7
        ITEM_SEVENDIGITAL_LEFT = 8
        ITEM_SEEN_AT = 9
      end

      class ChangeInfo
        include Beefcake::Message
      end

      class Delta
        include Beefcake::Message
      end

      class Merge
        include Beefcake::Message
      end

      class ChangeSet
        include Beefcake::Message

        module Kind
          KIND_UNKNOWN = 0
          DELTA = 2
          MERGE = 3
        end
      end

      class RevisionTaggedChangeSet
        include Beefcake::Message
      end

      class Diff
        include Beefcake::Message
      end

      class ListDump
        include Beefcake::Message
      end

      class ListChanges
        include Beefcake::Message
      end

      class SelectedListContent
        include Beefcake::Message
      end

      class Item
        include Beefcake::Message
      end

      class ListItems
        include Beefcake::Message
      end

      class ContentRange
        include Beefcake::Message
      end

      class ListContentSelection
        include Beefcake::Message
      end

      class ClientIssue
        include Beefcake::Message

        module Level
          LEVEL_UNKNOWN = 0
          LEVEL_DEBUG = 1
          LEVEL_INFO = 2
          LEVEL_NOTICE = 3
          LEVEL_WARNING = 4
          LEVEL_ERROR = 5
        end

        module Code
          CODE_UNKNOWN = 0
          CODE_INDEX_OUT_OF_BOUNDS = 1
          CODE_VERSION_MISMATCH = 2
          CODE_CACHED_CHANGE = 3
          CODE_OFFLINE_CHANGE = 4
          CODE_CONCURRENT_CHANGE = 5
        end
      end

      class ClientResolveAction
        include Beefcake::Message

        module Code
          CODE_UNKNOWN = 0
          CODE_NO_ACTION = 1
          CODE_RETRY = 2
          CODE_RELOAD = 3
          CODE_DISCARD_LOCAL_CHANGES = 4
          CODE_SEND_DUMP = 5
          CODE_DISPLAY_ERROR_MESSAGE = 6
        end

        module Initiator
          INITIATOR_UNKNOWN = 0
          INITIATOR_SERVER = 1
          INITIATOR_CLIENT = 2
        end
      end

      class ListChecksum
        include Beefcake::Message
      end

      class DownloadFormat
        include Beefcake::Message

        module Codec
          CODEC_UNKNOWN = 0
          OGG_VORBIS = 1
          FLAC = 2
          MPEG_1_LAYER_3 = 3
        end
      end

      class ListAttributes
        include Beefcake::Message
      end

      class ItemAttributes
        include Beefcake::Message
      end

      class StringAttribute
        include Beefcake::Message
      end

      class StringAttributes
        include Beefcake::Message
      end

      class Add
        include Beefcake::Message
      end

      class Rem
        include Beefcake::Message
      end

      class Mov
        include Beefcake::Message
      end

      class ItemAttributesPartialState
        include Beefcake::Message
      end

      class ListAttributesPartialState
        include Beefcake::Message
      end

      class UpdateItemAttributes
        include Beefcake::Message
      end

      class UpdateListAttributes
        include Beefcake::Message
      end

      class Op
        include Beefcake::Message

        module Kind
          KIND_UNKNOWN = 0
          ADD = 2
          REM = 3
          MOV = 4
          UPDATE_ITEM_ATTRIBUTES = 5
          UPDATE_LIST_ATTRIBUTES = 6
        end
      end

      class OpList
        include Beefcake::Message
      end

      class ChangeInfo
        optional :user, :string, 1
        optional :timestamp, :int32, 2
        optional :admin, :bool, 3
        optional :undo, :bool, 4
        optional :redo, :bool, 5
        optional :merge, :bool, 6
        optional :compressed, :bool, 7
        optional :migration, :bool, 8
      end


      class Delta
        optional :base_version, :bytes, 1
        repeated :ops, Op, 2
        optional :info, ChangeInfo, 4
      end


      class Merge
        optional :base_version, :bytes, 1
        optional :merge_version, :bytes, 2
        optional :info, ChangeInfo, 4
      end


      class ChangeSet
        required :kind, ChangeSet::Kind, 1
        optional :delta, Delta, 2
        optional :merge, Merge, 3
      end


      class RevisionTaggedChangeSet
        required :revision, :bytes, 1
        required :change_set, ChangeSet, 2
      end


      class Diff
        required :from_revision, :bytes, 1
        repeated :ops, Op, 2
        required :to_revision, :bytes, 3
      end


      class ListDump
        optional :latestRevision, :bytes, 1
        optional :length, :int32, 2
        optional :attributes, ListAttributes, 3
        optional :checksum, ListChecksum, 4
        optional :contents, ListItems, 5
        repeated :pendingDeltas, Delta, 7
      end


      class ListChanges
        optional :baseRevision, :bytes, 1
        repeated :deltas, Delta, 2
        optional :wantResultingRevisions, :bool, 3
        optional :wantSyncResult, :bool, 4
        optional :dump, ListDump, 5
        repeated :nonces, :int32, 6
      end


      class SelectedListContent
        optional :revision, :bytes, 1
        optional :length, :int32, 2
        optional :attributes, ListAttributes, 3
        optional :checksum, ListChecksum, 4
        optional :contents, ListItems, 5
        optional :diff, Diff, 6
        optional :syncResult, Diff, 7
        repeated :resultingRevisions, :bytes, 8
        optional :multipleHeads, :bool, 9
        optional :upToDate, :bool, 10
        repeated :resolveAction, ClientResolveAction, 12
        repeated :issues, ClientIssue, 13
        repeated :nonces, :int32, 14
      end


      class Item
        required :uri, :string, 1
        optional :attributes, ItemAttributes, 2
      end


      class ListItems
        required :pos, :int32, 1
        required :truncated, :bool, 2
        repeated :items, Item, 3
      end


      class ContentRange
        required :pos, :int32, 1
        optional :length, :int32, 2
      end


      class ListContentSelection
        optional :wantRevision, :bool, 1
        optional :wantLength, :bool, 2
        optional :wantAttributes, :bool, 3
        optional :wantChecksum, :bool, 4
        optional :wantContent, :bool, 5
        optional :contentRange, ContentRange, 6
        optional :wantDiff, :bool, 7
        optional :baseRevision, :bytes, 8
        optional :hintRevision, :bytes, 9
        optional :wantNothingIfUpToDate, :bool, 10
        optional :wantResolveAction, :bool, 12
        repeated :issues, ClientIssue, 13
        repeated :resolveAction, ClientResolveAction, 14
      end


      class ClientIssue
        optional :level, ClientIssue::Level, 1
        optional :code, ClientIssue::Code, 2
        optional :repeatCount, :int32, 3
      end


      class ClientResolveAction
        optional :code, ClientResolveAction::Code, 1
        optional :initiator, ClientResolveAction::Initiator, 2
      end


      class ListChecksum
        required :version, :int32, 1
        optional :sha1, :bytes, 4
      end


      class DownloadFormat
        required :codec, DownloadFormat::Codec, 1
      end


      class ListAttributes
        optional :name, :string, 1
        optional :description, :string, 2
        optional :picture, :bytes, 3
        optional :collaborative, :bool, 4
        optional :pl3_version, :string, 5
        optional :deleted_by_owner, :bool, 6
        optional :restricted_collaborative, :bool, 7
      end


      class ItemAttributes
        optional :added_by, :string, 1
        optional :timestamp, :int64, 2
        optional :message, :string, 3
        optional :seen, :bool, 4
        optional :download_count, :int64, 5
        optional :download_format, DownloadFormat, 6
        optional :sevendigital_id, :string, 7
        optional :sevendigital_left, :int64, 8
        optional :seen_at, :int64, 9
      end


      class StringAttribute
        required :key, :string, 1
        required :value, :string, 2
      end


      class StringAttributes
        repeated :attribute, StringAttribute, 1
      end


      class Add
        optional :fromIndex, :int32, 1
        repeated :items, Item, 2
        optional :list_checksum, ListChecksum, 3
        optional :addLast, :bool, 4
        optional :addFirst, :bool, 5
      end


      class Rem
        optional :fromIndex, :int32, 1
        optional :length, :int32, 2
        repeated :items, Item, 3
        optional :list_checksum, ListChecksum, 4
        optional :items_checksum, ListChecksum, 5
        optional :uris_checksum, ListChecksum, 6
        optional :itemsAsKey, :bool, 7
      end


      class Mov
        required :fromIndex, :int32, 1
        required :length, :int32, 2
        required :toIndex, :int32, 3
        optional :list_checksum, ListChecksum, 4
        optional :items_checksum, ListChecksum, 5
        optional :uris_checksum, ListChecksum, 6
      end


      class ItemAttributesPartialState
        required :values, ItemAttributes, 1
        repeated :no_value, ItemAttributeKind, 2
      end


      class ListAttributesPartialState
        required :values, ListAttributes, 1
        repeated :no_value, ListAttributeKind, 2
      end


      class UpdateItemAttributes
        required :index, :int32, 1
        required :new_attributes, ItemAttributesPartialState, 2
        optional :old_attributes, ItemAttributesPartialState, 3
        optional :list_checksum, ListChecksum, 4
        optional :old_attributes_checksum, ListChecksum, 5
      end


      class UpdateListAttributes
        required :new_attributes, ListAttributesPartialState, 1
        optional :old_attributes, ListAttributesPartialState, 2
        optional :list_checksum, ListChecksum, 3
        optional :old_attributes_checksum, ListChecksum, 4
      end


      class Op
        required :kind, Op::Kind, 1
        optional :add, Add, 2
        optional :rem, Rem, 3
        optional :mov, Mov, 4
        optional :update_item_attributes, UpdateItemAttributes, 5
        optional :update_list_attributes, UpdateListAttributes, 6
      end


      class OpList
        repeated :ops, Op, 1
      end

    end
  end
end
