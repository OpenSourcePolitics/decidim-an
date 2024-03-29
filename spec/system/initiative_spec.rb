# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the initiative does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_initiatives.initiative_path(99_999_999) }
    end
  end

  describe "initiative page" do
    let!(:initiative) { base_initiative }
    let(:attached_to) { initiative }

    before do
      visit decidim_initiatives.initiative_path(initiative)
    end

    #  TODO: Investigate and fix
    #
    # it "shows the details of the given initiative" do
    #   within "main" do
    #     expect(page).to have_content(translated(initiative.title, locale: :en))
    #     expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
    #     expect(page).to have_content(translated(initiative.type.title, locale: :en))
    #     expect(page).to have_content(initiative.author_name)
    #     expect(page).to have_content(initiative.hashtag)
    #     expect(page).to have_content(initiative.reference)
    #   end
    # end

    it "shows the author name once in the authors list" do
      within ".initiative-authors" do
        expect(page).to have_content(initiative.author_name, count: 1)
      end
    end

    #  TODO: Investigate and fix
    #
    # it "displays date" do
    #   within ".process-header__phase" do
    #     expect(page).to have_content(I18n.l(base_initiative.signature_start_date, format: :decidim_short))
    #     expect(page).to have_content(I18n.l(base_initiative.signature_end_date, format: :decidim_short))
    #   end
    # end

    context "when in a manual state" do
      let(:base_initiative) { create(:initiative, :debatted, :with_answer, organization: organization) }

      it "displays the initiative status with the appropriate color" do
        expect(page).to have_css(".initiative-status.success")
        expect(page).to have_css(".initiative-answer.success")
      end

      it "displays date" do
        expect(page).to have_content(I18n.l(base_initiative.answer_date.to_date, format: :decidim_short))
      end
    end

    #  TODO: Investigate and fix
    #
    # context "when sharing initiative" do
    #   it "displays social links in view-side" do
    #     within ".view-side" do
    #       within ".social-share-button" do
    #         expect(page).to have_selector("a[title=\"Share to Twitter\"]", count: 1)
    #         expect(page).to have_selector("a[title=\"Share to Facebook\"]", count: 1)
    #       end
    #     end
    #   end
    # end

    describe "when answering an initiative" do
      context "when an initiative is rejected" do
        let!(:initiative) { create(:initiative, :rejected, organization: organization) }

        it "displays state_badge_css_class rejected callout" do
          expect(page).to have_css(".initiative-answer")
          expect(page).to have_content "This initiative has been rejected due to its lack of signatures."
        end
      end

      context "when an initiative is open" do
        let!(:initiative) { create(:initiative, :with_answer, organization: organization) }

        it "displays state_badge_css_class callout with answer state" do
          expect(page).to have_css(".initiative-answer")
          expect(page).to have_content("This proposal is published because")
        end
      end
    end

    #  TODO: Investigate and fix
    #
    # it_behaves_like "has attachments"
  end
end
