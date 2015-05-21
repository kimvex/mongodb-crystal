class Mongo::GridFS::File
  include IO

  property! timeout_msec

  def initialize(@handle: LibMongoC::GFSFile, @timeout_msec = 5000_u32)
    raise "invalid handle" unless @handle
  end

  def finalize
    LibMongoC.gridfs_file_destroy(@handle)
  end

  def aliases
    handle = LibMongoC.gridfs_file_get_aliases(self)
    BSON.new handle if handle
  end

  def aliases=(value)
    handle = LibMongoC.gridfs_file_set_aliases(self, value.to_bson)
    BSON.new handle if handle
  end

  def chunk_size
    LibMongoC.gridfs_file_get_chunk_size(self)
  end

  def content_type
    handle = LibMongoC.gridfs_file_get_content_type(self)
    handle ? String.new handle : ""
  end

  def content_type=(value)
    LibMongoC.gridfs_file_set_content_type(self, value)
  end

  def name
    handle = LibMongoC.gridfs_file_get_filename(self)
    handle ? String.new handle : ""
  end

  def name=(value)
    LibMongoC.gridfs_file_set_filename(self, value)
  end

  def length
    LibMongoC.gridfs_file_get_length(self)
  end

  def md5
    handle = LibMongoC.gridfs_file_get_md5(self)
    handle ? String.new handle : ""
  end

  def md5=(value)
    LibMongoC.gridfs_file_set_md5(self, value)
  end

  def metadata
    handle = LibMongoC.gridfs_file_get_metadata(self)
    BSON.new handle if handle
  end

  def metadata=(value)
    LibMongoC.gridfs_file_set_metadata(self, value.to_bson)
  end

  def upload_date
    epoch = LibMongoC.gridfs_file_get_upload_date(self)
    spec = LibC::TimeSpec.new
    spec.tv_sec = epoch / 1000
    Time.new(spec, Time::Kind::Utc)
  end

  def remove
    LibMongoC.gridfs_file_remove(self, out error).tap do |res|
      raise BSON::BSONError.new(pointerof(error)) unless res
    end
  end

  def save
    LibMongoC.gridfs_file_save(self).tap do
      check_error
    end
  end

  def seek(amount, whence = LibC::SEEK_SET)
    LibMongoC.gridfs_file_seek(self, amount.to_i64, whence).tap do
      check_error
    end
  end

  def tell
    LibMongoC.gridfs_file_tell(self).tap do
      check_error
    end
  end

  def read(slice: Slice(UInt8), length)
    iov = LibMongoC::IOVec.new
    iov.ion_base = slice.pointer(length)
    iov.ion_len = length.to_u64

    len = LibMongoC.gridfs_file_readv(self, pointerof(iov),
                                      LibC::SizeT.cast(1),
                                      LibC::SizeT.cast(0),
                                      @timeout_msec.to_u32)
    check_error
    len
  end

  def write(slice: Slice(UInt8), length)
    iov = LibMongoC::IOVec.new
    iov.ion_base = slice.pointer(length)
    iov.ion_len = length.to_u64

    len = LibMongoC.gridfs_file_writev(self, pointerof(iov),
                                       LibC::SizeT.cast(1),
                                       @timeout_msec.to_u32)
    check_error
    len
  end

  private def check_error
    if LibMongoC.gridfs_file_error(@handle, out error)
      raise BSON::BSONError.new(pointerof(error))
    end
  end

  def to_s(io)
    io << name
  end

  def inspect(io)
    io << "GridFS::File "
    io << "name: #{name}, "
    io << "aliases: #{aliases}, "
    io << "content_type: #{content_type}, "
    io << "length: #{length}, "
    io << "md5: #{md5}, "
    io << "metadata: #{metadata}, "
    io << "upload_date: #{upload_date.to_local}"
  end

  def to_unsafe
    @handle
  end
end
