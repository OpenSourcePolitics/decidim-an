# frozen_string_literal: true

module Decidim
  module Admin
    # Helper that provides methods related to Decidim::Admin::Filterable concern.
    module FilterableHelper
      # Renders the filters selector with tags in the admin panel.
      def admin_filter_selector
        render partial: "decidim/admin/shared/filters"
      end

      # Builds a tree of links from Decidim::Admin::Filterable::filters_with_values
      def submenu_options_tree
        filters_with_values.each_with_object({}) do |(filter, values), hash|
          next if filter == :type_id_eq

          values = reorder_states(values) if filter == :state_eq

          link = filter_link_label(filter)
          hash[link] = if values.is_a?(Array)
                         build_submenu_options_tree_from_array(filter, values)
                       elsif values.is_a?(Hash)
                         build_submenu_options_tree_from_hash(filter, values)
                       end
        end
      end

      # Builds a tree of links from an array. The tree will have only one level.
      def build_submenu_options_tree_from_array(filter, values)
        links = []
        links += extra_dropdown_submenu_options_items(filter)
        links += values.map do |value|
          next if value == "rejected"
          next if value == "accepted"

          filter_link_value(filter, value)
        end
        links.each_with_object({}) { |link, hash| hash[link] = nil }
      end

      # To be overriden. Useful for adding links that do not match with the filter.
      # Must return an Array.
      def extra_dropdown_submenu_options_items(_filter)
        []
      end

      # Builds a tree of links from an Hash. The tree can have many levels.
      def build_submenu_options_tree_from_hash(filter, values)
        values.each_with_object({}) do |(key, value), hash|
          link = filter_link_value(filter, key)
          hash[link] = if value.nil?
                         nil
                       elsif value.is_a?(Hash)
                         build_submenu_options_tree_from_hash(filter, value)
                       end
        end
      end

      # Produces the html for the dropdown submenu from the options tree.
      # Returns a ActiveSupport::SafeBuffer.
      def dropdown_submenu(options)
        content_tag(:ul, class: "vertical menu") do
          options.map do |key, value|
            if value.nil?
              content_tag(:li, key)
            elsif value.is_a?(Hash)
              content_tag(:li, class: "is-dropdown-submenu-parent") do
                key + dropdown_submenu(value)
              end
            end
          end.join.html_safe
        end
      end

      def filter_link_label(filter)
        link_to(i18n_filter_label(filter), href: "#")
      end

      def filter_link_value(filter, value)
        link_to(i18n_filter_value(filter, value), query_params_with(filter => value))
      end

      def i18n_filter_label(filter)
        t("decidim.admin.filters.#{filter}.label")
      end

      def i18n_filter_value(filter, value)
        if I18n.exists?("decidim.admin.filters.#{filter}.values.#{value}")
          t(value, scope: "decidim.admin.filters.#{filter}.values")
        else
          find_dynamic_translation(filter, value)
        end
      end

      def applied_filters_hidden_field_tags
        html = []
        html += ransack_params.slice(*filters, *extra_filters).map do |filter, value|
          hidden_field_tag("q[#{filter}]", value)
        end
        html += query_params.slice(*extra_allowed_params).map do |filter, value|
          hidden_field_tag(filter, value)
        end
        html.join.html_safe
      end

      def applied_filters_tags
        ransack_params.slice(*filters).map do |filter, value|
          applied_filter_tag(filter, value)
        end.join.html_safe
      end

      def applied_filter_tag(filter, value)
        content_tag(:span, class: "label secondary") do
          concat "#{i18n_filter_label(filter)}: "
          concat i18n_filter_value(filter, value)
          concat remove_filter_icon_link(filter)
        end
      end

      def remove_filter_icon_link(filter)
        icon_link_to(
          "circle-x",
          url_for(query_params_without(filter)),
          t("decidim.admin.actions.cancel"),
          class: "action-icon--remove"
        )
      end

      private

      def reorder_states(states)
        ordered_states = []

        ordered_states << "created" if states.member?("created")
        ordered_states << "validating" if states.member?("validating")
        ordered_states << "discarded" if states.member?("discarded")
        ordered_states << "published" if states.member?("published")
        ordered_states << "classified" if states.member?("classified")
        ordered_states << "examinated" if states.member?("examinated")
        ordered_states << "debatted" if states.member?("debatted")

        ordered_states
      end
    end
  end
end
