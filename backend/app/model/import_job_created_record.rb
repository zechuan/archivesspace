class ImportJobCreatedRecord < Sequel::Model(:import_job_created_record)
  include ASModel

  set_model_scope :global


  def self.sequel_to_jsonmodel(obj, opts = {})
    {'record' => {'ref' => obj.record_uri}}
  end
end
