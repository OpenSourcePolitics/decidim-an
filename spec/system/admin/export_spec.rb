# frozen_string_literal: true

require "spec_helper"

describe "Admin exports initiatives", type: :system do
  include_context "with filterable context"

  let!(:initiatives) do
    create_list(:initiative, 3, organization: organization)
  end

  let!(:created_initiative) do
    create(:initiative, :created, organization: organization)
  end

  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when accessing initiatives list" do
    it "shows both of the export dropdowns" do
      visit decidim_admin_initiatives.initiatives_path

      within ".card-title" do
        expect(page).to have_content("ALL")
        expect(page).to have_content("SELECTION")
      end
    end
  end

  context "when clicking the export dropdown" do
    before do
      visit decidim_admin_initiatives.initiatives_path
    end

    it "shows the export formats" do
      find("span", text: "EXPORT ALL").click

      expect(page).to have_content("AS CSV")
      expect(page).to have_content("AS JSON")
    end
  end

  context "when clicking the export link" do
    before do
      visit decidim_admin_initiatives.initiatives_path
      find("span", text: "EXPORT SELECTION").click
    end

    it "displays success message" do
      find("button", text: "EXPORT AS JSON").click
      expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
    end
  end

  context "when initiatives are filtered" do
    context "when we have no result for the filter" do
      before do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Classified")
      end

      it "shows only the export all dropdown" do
        expect(page).to have_content("EXPORT ALL")
        expect(page).to have_no_content("EXPORT SELECTION")
      end
    end

    context "when accessing initiatives list" do
      it "shows the export dropdown" do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")

        within ".card-title" do
          expect(page).to have_content("ALL")
          expect(page).to have_content("SELECTION")
        end
      end
    end

    context "when clicking the export dropdown" do
      before do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")
      end

      it "shows the export formats" do
        find("span", text: "EXPORT SELECTION").click

        expect(page).to have_content("AS CSV")
        expect(page).to have_content("AS JSON")
      end
    end

    context "when clicking the export link" do
      before do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")
        find("span", text: "SELECTION").click
      end

      it "displays success message" do
        find("button", text: "EXPORT AS JSON").click

        expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
      end
    end
  end
end
