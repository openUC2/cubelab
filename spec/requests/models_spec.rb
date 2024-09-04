require "rails_helper"

#    edit_model GET    /models/:id/edit(.:format)                        models#edit
#         model GET    /models/:id(.:format)                             models#show
#               PATCH  /models/:id(.:format)                             models#update
#               PUT    /models/:id(.:format)                             models#update
#               DELETE /models/:id(.:format)                             models#destroy
#   edit_models GET    /models/edit(.:format)                                                  models#bulk_edit
# update_models PATCH  /models/update(.:format)                                                models#bulk_update
#        models GET    /models(.:format)                                                       models#index
#     new_model GET    /models/new(.:format)                                                      uploads#index
#               POST   /models(.:format)                                                      uploads#create
#   merge_model POST   /models/:id/merge(.:format)                       models#merge
#   scan_model  POST   /models/:id/scan(.:format)                        models#scan

RSpec.describe "Models" do
  context "when signed out" do
    it "needs testing when multiuser is enabled"
  end

  context "when signed in" do
    let!(:creator) { create(:creator) }
    let!(:collection) { create(:collection) }
    let!(:library) do
      l = create(:library)
      build_list(:model, 5, library: l) { |x| x.save! }
      build_list(:model, 5, library: l, creator: creator) { |x| x.save! }
      build_list(:model, 5, library: l, collection: collection) { |x| x.save! }
      build_list(:model, 5, library: l, creator: creator, collection: collection) { |x| x.save! }
      l
    end

    describe "GET /models/:id", :as_member do
      it "returns http success" do
        get "/models/#{library.models.first.to_param}"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /models/:id/edit" do
      it "shows edit page for file", :as_moderator do
        get "/models/#{library.models.first.to_param}/edit"
        expect(response).to have_http_status(:success)
      end

      it "is denied to non-moderators", :as_contributor do
        expect { get "/models/#{library.models.first.to_param}/edit" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "PUT /models/:id" do
      it "adds tags to a model", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        put "/models/#{library.models.first.to_param}", params: {model: {tag_list: ["a", "b", "c"]}}
        expect(response).to have_http_status(:redirect)
        tags = library.models.first.tag_list
        expect(tags.length).to eq 3
        expect(tags[0]).to eq "a"
        expect(tags[1]).to eq "b"
        expect(tags[2]).to eq "c"
      end

      it "removes tags from a model", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        first = library.models.first
        first.tag_list = "a, b, c"
        first.save

        put "/models/#{library.models.first.to_param}", params: {model: {tag_list: ["a", "b"]}}
        expect(response).to have_http_status(:redirect)
        first.reload
        tags = first.tag_list
        expect(tags.length).to eq 2
        expect(tags[0]).to eq "a"
        expect(tags[1]).to eq "b"
      end

      it "both adds and removes tags from a model", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        first = library.models.first
        first.tag_list = "a, b, c"
        first.save

        put "/models/#{library.models.first.to_param}", params: {model: {tag_list: ["a", "b", "d"]}}
        expect(response).to have_http_status(:redirect)
        first.reload
        tags = first.tag_list
        expect(tags.length).to eq 3
        expect(tags[0]).to eq "a"
        expect(tags[1]).to eq "b"
        expect(tags[2]).to eq "d"
      end

      it "is denied to non-moderators", :as_contributor do
        expect { put "/models/#{library.models.first.to_param}" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "DELETE /models/:id" do # rubocop:todo RSpec/RepeatedExampleGroupBody
      it "redirects to model list after deletion", :as_moderator do
        delete "/models/#{library.models.first.to_param}"
        expect(response).to redirect_to("/")
      end

      it "is denied to non-moderators", :as_contributor do
        expect { delete "/models/#{library.models.first.to_param}" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "GET /models/edit" do # rubocop:todo RSpec/RepeatedExampleGroupBody
      it "shows bulk edit page", :as_moderator do
        get "/models/edit"
        expect(response).to have_http_status(:success)
      end

      it "is denied to non-moderators", :as_contributor do
        expect { get "/models/edit" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "PATCH /models/edit" do
      it "updates models creator", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        models = library.models.take(2)
        update = {}
        update[models[0].id] = 1
        update[models[1].id] = 1

        patch "/models/update", params: {models: update, creator_id: creator.to_param}

        expect(response).to have_http_status(:redirect)
        models.each { |model| model.reload }
        expect(models[0].creator_id).to eq creator.id
        expect(models[1].creator_id).to eq creator.id
      end

      it "adds tags to models", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        update = {}
        library.models.take(2).each do |model|
          update[model.id] = 1
        end

        patch "/models/update", params: {models: update, add_tags: ["a", "b", "c"]}

        expect(response).to have_http_status(:redirect)
        library.models.take(2).each do |model|
          expect(model.tag_list).to eq ["a", "b", "c"]
        end
      end

      it "removes tags from models", :as_moderator do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
        update = {}
        library.models.take(2).each do |model|
          model.tag_list = "a, b, c"
          model.save
          update[model.id] = 1
        end

        patch "/models/update", params: {models: update, remove_tags: ["a", "b"]}

        expect(response).to have_http_status(:redirect)
        library.models.take(2).each do |model|
          model.reload
          expect(model.tag_list).to eq ["c"]
        end
      end

      it "is denied to non-moderators", :as_contributor do
        update = {}
        expect { patch "/models/update", params: {models: update, remove_tags: ["a", "b"]} }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "GET /models", :as_member do
      it "allows search queries" do
        get "/models?q=#{library.models.first.name}"
        expect(response).to have_http_status(:success)
      end

      it "allows tag filters" do
        m = library.models.first
        m.tag_list << "test"
        m.save
        get "/models?tag[]=test"
        expect(response).to have_http_status(:success)
      end

      it "allows link filters" do
        get "/models?link="
        expect(response).to have_http_status(:success)
      end

      it "returns paginated models" do # rubocop:todo RSpec/MultipleExpectations
        get "/models?library=#{library.to_param}&page=2"
        expect(response).to have_http_status(:success)
        expect(response.body).to match(/pagination/)
      end
    end

    describe "POST /models/:id/merge" do
      it "gives a bad request response if no merge parameter is provided", :as_moderator do
        post "/models/#{library.models.first.to_param}/merge"
        expect(response).to have_http_status(:bad_request)
      end

      it "is denied to non-moderators", :as_contributor do
        expect { post "/models/#{library.models.first.to_param}/merge" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "POST /models/:id/scan" do
      it "schedules a scan job", :as_moderator do
        expect { post "/models/#{library.models.first.to_param}/scan" }.to(
          have_enqueued_job(Scan::CheckModelJob).with(library.models.first.id).once
        )
      end

      it "redirects back to model page", :as_contributor do
        post "/models/#{library.models.first.to_param}/scan"
        expect(response).to redirect_to("/models/#{library.models.first.public_id}")
      end

      it "is denied to non-contributors", :as_member do
        expect { post "/models/#{library.models.first.to_param}/scan" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "GET /models/new" do
      it "shows upload form", :as_contributor do
        get "/models/new"
        expect(response).to have_http_status(:success)
      end

      it "denies member permission", :as_member do
        expect { get "/models/new" }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "POST /models" do
      it "redirect back to index after upload", :as_contributor do
        post "/models", params: {library: library.id, scan: "1", uploads: "{}"}
        expect(response).to redirect_to("/libraries")
      end

      it "denies member permission", :as_member do
        expect { post "/models", params: {post: {library_pick: library.id, scan_after_upload: "1"}, upload: {datafiles: []}} }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
