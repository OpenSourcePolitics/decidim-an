# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccountMailer, type: :mailer do
    let(:organization) { create(:organization) }
    let(:admin) { create(:user, :admin, organization: organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:initiative) { create(:initiative, organization: organization, state: :published) }

    let(:default_subject) { "A user has deleted his account." }
    let(:default_body) { "A user has deleted his account. We invite you to go and file his petitions." }

    describe "#notify" do
      let(:mail) { described_class.notify(admin, initiative.author) }

      it "notify admins" do
        expect(mail.to).not_to include(user.email)
        expect(mail.to).to include(admin.email)
        expect(mail.subject).to eq(default_subject)
        expect(mail.body.encoded).to match(default_body)
        expect(mail.body.encoded).to match(initiative.id.to_s)
        expect(mail.body.encoded).to match(translated(initiative.title))
        expect(mail.body.encoded).to match(I18n.t(initiative.state, scope: "decidim.initiatives.state"))
        expect(mail.body.encoded).to match("<a href=\"http://#{organization.host}/admin/initiatives/i-#{initiative.id}/edit\">Manage</a>")
      end

      context "when user has no initiative" do
        let!(:initiative) { nil }
        let(:mail) { described_class.notify(admin, user) }

        it "notify admins" do
          expect(mail.subject).to eq(default_subject)
          expect(mail.body.encoded).to match(default_body)
        end
      end

      context "when initiative has created status" do
        let!(:initiative) { create(:initiative, organization: organization, state: :created) }
        let(:mail) { described_class.notify(admin, initiative.author) }

        it "notify admins" do
          expect(mail.subject).to eq(default_subject)
          expect(mail.body.encoded).to match(default_body)
        end
      end

      context "when initiative has discarded status" do
        let!(:initiative) { create(:initiative, organization: organization, state: :discarded) }
        let(:mail) { described_class.notify(admin, initiative.author) }

        it "notify admins" do
          expect(mail.subject).to eq(default_subject)
          expect(mail.body.encoded).to match(default_body)
        end
      end

      context "when initiative has classified status" do
        let!(:initiative) { create(:initiative, organization: organization, state: :classified) }
        let(:mail) { described_class.notify(admin, initiative.author) }

        it "notify admins" do
          expect(mail.subject).to eq(default_subject)
          expect(mail.body.encoded).to match(default_body)
        end
      end
    end
  end
end
