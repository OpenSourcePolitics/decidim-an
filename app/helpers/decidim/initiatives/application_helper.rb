# frozen_string_literal: true

module Decidim
  module Initiatives
    # Custom helpers, scoped to the initiatives engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::CachingHelper

      def filter_states_values
        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
          [
            TreePoint.new("open", t("decidim.initiatives.application_helper.filter_state_values.open")),
            TreeNode.new(
              TreePoint.new("closed", t("decidim.initiatives.application_helper.filter_state_values.closed")),
              [
                TreePoint.new("accepted", t("decidim.initiatives.application_helper.filter_state_values.accepted")),
                TreePoint.new("rejected", t("decidim.initiatives.application_helper.filter_state_values.rejected"))
              ]
            ),
            TreeNode.new(
              TreePoint.new("archived", t("decidim.initiatives.application_helper.filter_state_values.archived")),
              archives_categories_value
            )
          ]
        )
      end

      def filter_sorts_values
        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
          [
            TreePoint.new("published", t("decidim.initiatives.application_helper.filter_state_values.published")),
            TreePoint.new("classified", t("decidim.initiatives.application_helper.filter_state_values.classified")),
            TreePoint.new("examinated", t("decidim.initiatives.application_helper.filter_state_values.examinated")),
            TreePoint.new("debatted", t("decidim.initiatives.application_helper.filter_state_values.debatted"))
          ]
        )
      end

      def filter_scopes_values
        Rails.cache.fetch(current_organization.scopes.cache_key) do
          main_scopes = current_organization.scopes.top_level

          scopes_values = main_scopes.includes(:scope_type, :children).flat_map do |scope|
            TreeNode.new(
              TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_organization)),
              scope_children_to_tree(scope)
            )
          end

          scopes_values.prepend(TreePoint.new("global", t("decidim.scopes.global")))

          TreeNode.new(
            TreePoint.new("", t("decidim.initiatives.application_helper.filter_scope_values.all")),
            scopes_values
          )
        end
      end

      def scope_children_to_tree(scope)
        return unless scope.children.any?

        scope.children.includes(:scope_type, :children).flat_map do |child|
          TreeNode.new(
            TreePoint.new(child.id.to_s, translated_attribute(child.name, current_organization)),
            scope_children_to_tree(child)
          )
        end
      end

      def filter_types_values
        types_values = Decidim::InitiativesType.where(organization: current_organization).map do |type|
          TreeNode.new(
            TreePoint.new(type.id.to_s, type.title[I18n.locale.to_s])
          )
        end

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_type_values.all")),
          types_values
        )
      end

      def filter_areas_values
        areas_or_types = areas_for_select(current_organization)

        areas_values = if areas_or_types.first.is_a?(Decidim::Area)
                         filter_areas(areas_or_types)
                       else
                         filter_areas_and_types(areas_or_types)
                       end

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_area_values.all")),
          areas_values
        )
      end

      def filter_areas(areas)
        areas.map do |area|
          TreeNode.new(
            TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
          )
        end
      end

      def filter_areas_and_types(area_types)
        area_types.map do |area_type|
          TreeNode.new(
            TreePoint.new(area_type.area_ids.join("_"), area_type.name[I18n.locale.to_s]),
            area_type.areas.map do |area|
              TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
            end
          )
        end
      end

      def archives_categories_value
        archive_categories.map { |archive_category| TreePoint.new(archive_category.name, archive_category.name) }
      end

      def archive_categories
        @archive_categories ||= Decidim::InitiativesArchiveCategory.where(organization: current_organization)
      end
    end
  end
end
