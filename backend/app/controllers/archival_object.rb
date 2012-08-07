class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/archival_objects')
    .params(["archival_object", JSONModel(:archival_object), "The archival_object to create", :body => true],
            ["repo_id", Integer, "The repository ID"])
    .returns([200, "OK"]) \
  do
    ao = ArchivalObject.create_from_json(params[:archival_object],
                                         :repo_id => params[:repo_id])

    parent_id = JSONModel::parse_reference(params[:archival_object].parent,
                                           :repo_id => params[:repo_id])

    collection_id = JSONModel::parse_reference(params[:archival_object].collection,
                                               :repo_id => params[:repo_id])


    if collection_id
      collection = Collection.get_or_die(collection_id[:id])

      collection.link(:parent => parent_id ? parent_id[:id] : nil,
                      :child => ao[:id])
    end

    created_response(ao[:id], params[:archival_object]._warnings)
  end


  Endpoint.post('/repositories/:repo_id/archival_objects/:archival_object_id')
    .params(["archival_object_id", Integer, "The archival object ID to update"],
            ["archival_object", JSONModel(:archival_object), "The archival object data to update", :body => true])
    .returns([200, "OK"]) \
  do
    ao = ArchivalObject.get_or_die(params[:archival_object_id])
    ao.update_from_json(params[:archival_object])

    json_response({:status => "Updated", :id => ao[:id]})
  end


  Endpoint.get('/repositories/:repo_id/archival_objects/:archival_object_id')
    .params(["archival_object_id", Integer, "The archival object ID"],
            ["repo_id", Integer, "The repository ID"])
    .returns([200, "OK"]) \
  do
    ArchivalObject.to_jsonmodel(params[:archival_object_id], :archival_object).to_json
  end


  Endpoint.get('/repositories/:repo_id/archival_objects/:archival_object_id/children')
    .params(["archival_object_id", Integer, "The archival object ID"],
            ["repo_id", Integer, "The repository ID"])
    .returns([200, "OK"]) \
  do
    ao = ArchivalObject.get_or_die(params[:archival_object_id])
    json_response(ao.children.map {|child|
                    ArchivalObject.to_jsonmodel(child, :archival_object).to_hash})
  end


  Endpoint.get('/repositories/:repo_id/archival_objects')
    .params(["repo_id", Integer, "The ID of the repository containing the archival object"])
    .returns([200, "OK"]) \
  do
    json_response(ArchivalObject.filter({:repo_id => params[:repo_id]}).
                                 collect {|ao| ArchivalObject.to_jsonmodel(ao, :archival_object).to_hash})
  end

end