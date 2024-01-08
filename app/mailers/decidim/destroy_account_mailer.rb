# frozen_string_literal: true

module Decidim
  class DestroyAccountMailer < Decidim::ApplicationMailer
    include Decidim::TranslatableAttributes

    add_template_helper Decidim::TranslatableAttributes

    def notify(admin, user)
      with_user(user) do
        @organization = admin.organization
        @admin = admin
        @user = user
        @initiatives = Decidim::Initiative.where(author: @user).where.not(state: [:created, :discarded, :classified])

        subject = I18n.t("notify.subject", scope: "decidim.destroy_account_mailer")
        mail(to: @admin.email, subject: subject)
      end
    end

    def decidim_admin_initiatives
      Decidim::Admin::Initiatives::Engine.routes.url_helpers
    end
  end
end
