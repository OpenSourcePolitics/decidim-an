# frozen_string_literal: true

require "spec_helper"

describe "Edit initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:initiative_title) { translated(initiative.title) }
  let(:new_title) { "This is my <h2>initiative</h2> new title" }
  let(:new_body) { "This my corrupted <h2>edited initiative</h2> with a code injection <script>alert('Injection');</script>" }

  let!(:initiative_type) { create(:initiatives_type, :online_signature_enabled, organization: organization) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let!(:other_initiative_type) { create(:initiatives_type, organization: organization) }
  let!(:other_scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let(:initiative_path) { decidim_initiatives.initiative_path(initiative) }
  let(:edit_initiative_path) { decidim_initiatives.edit_initiative_path(initiative) }

  shared_examples "manage update" do
    it "can be updated" do
      visit initiative_path

      click_link("Edit", href: edit_initiative_path)

      expect(page).to have_content "EDIT INITIATIVE"

      within "form.edit_initiative" do
        fill_in :initiative_title, with: new_title
        fill_in :initiative_description, with: new_body
        click_button "Update"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content("This my corrupted edited initiative with a code injection")
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "when user is initiative author" do
    let(:initiative) { create(:initiative, :created, author: user, scoped_type: scoped_type, organization: organization) }

    #  TODO: Investigate and fix
    #
    # it_behaves_like "manage update"

    context "when initiative is published" do
      let(:initiative) { create(:initiative, author: user, scoped_type: scoped_type, organization: organization) }

      it "can't be updated" do
        visit decidim_initiatives.initiative_path(initiative)

        expect(page).not_to have_content "Edit initiative"

        visit edit_initiative_path

        expect(page).to have_content("not authorized")
      end
    end
  end

  # describe "when author is a committee member" do
  #   let(:initiative) { create(:initiative, :created, scoped_type: scoped_type, organization: organization) }
  #
  #   before do
  #     create(:initiatives_committee_member, user: user, initiative: initiative)
  #   end

  #  TODO: Investigate and fix
  #
  # it_behaves_like "manage update"
  # end

  # describe "when user is admin" do
  #   let(:user) { create(:user, :confirmed, :admin, organization: organization) }
  #   let(:initiative) { create(:initiative, :created, scoped_type: scoped_type, organization: organization) }
  #
  #  TODO: Investigate and fix
  #
  # it_behaves_like "manage update"
  # end

  describe "when author is not a committee member" do
    let(:initiative) { create(:initiative, :created, scoped_type: scoped_type, organization: organization) }

    it "renders an error" do
      visit decidim_initiatives.initiative_path(initiative)

      expect(page).to have_no_content("Edit initiative")

      visit edit_initiative_path

      expect(page).to have_content("not authorized")
    end
  end
end
