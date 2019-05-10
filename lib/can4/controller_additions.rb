# frozen_string_literal: true

module Can4
  # Rails controller additions for Can4.
  #
  # In most cases, it is not necessary to define anything here, as it is
  # included for you automatically when +ActionController::Base+ is defined.
  #
  # However, if your controller resource is not defined using a method named
  # +current_user+, or you use different arguments for your +Ability+
  # constructor, you will need to override the +current_ability+ method in
  # your controller.
  #
  # @example
  #   class ApplicationController < ActionController::Base
  #     # ...
  #
  #     private
  #
  #     # This example shows a possible redefinition of current_ability
  #     # with a different scope and two constructor arguments.
  #     def current_ability
  #       @current_ability ||= ::Ability.new(current_admin, request.remote_ip)
  #     end
  #   end
  #
  module ControllerAdditions
    module ClassMethods
      # Add this to a controller to ensure it performs authorization through an
      # {#authorize!} call.
      #
      # If neither of these authorization methods are called, a
      # {Can4::AuthorizationNotPerformed} exception will be raised.
      #
      # This can be placed in your ApplicationController to ensure all
      # controller actions perform authorization.
      def check_authorization(*args)
        after_action(*args) do |controller|
          next if controller.instance_variable_defined?(:@_authorized)

          raise AuthorizationNotPerformed,
            'This action failed to check_authorization because it did not ' \
            'authorize a resource. Add skip_authorization_check to bypass ' \
            'this check.'
        end
      end

      # Call this in the class of a controller to skip the check_authorization
      # behavior on the actions. Arguments are the same as +before_action+.
      def skip_authorization_check(*args)
        before_action(*args) do |controller|
          controller.instance_variable_set(:@_authorized, true)
        end
      end
    end

    # Raises a {Can4::AccessDenied} exception if the current ability cannot
    # perform the given action. This is usually called in a controller action
    # or +before_action+.
    #
    # You can rescue from the exception in the controller to customize how
    # unauthorized access is displayed.
    #
    # @raise [Can4::AccessDenied]
    #   The current ability cannot perform the requested action.
    def authorize!(*args)
      @_authorized = true
      current_ability.authorize!(*args)
    end

    # Creates and returns the current ability and caches it. If you want to
    # override how the +Ability+ is defined, then this is the place. Simply
    # redefine the method in the controller to change its behavior.
    #
    # Note that it is important to memoize the ability object so it is not
    # recreated every time.
    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end

    # Use in the controller or view to check the resources's permission for a
    # given action and object. This simply calls #can? on the current ability.
    #
    # @see Ability#can?
    def can?(*args)
      current_ability.can?(*args)
    end

    # Convenience method which works the same as {#can?}, but returns the
    # opposite value.
    #
    # @see Ability#cannot?
    def cannot?(*args)
      current_ability.cannot?(*args)
    end

    def self.included(base)
      base.extend ClassMethods

      return unless base.respond_to?(:helper_method)

      base.helper_method :can?, :cannot?, :current_ability
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.class_eval do
    include Can4::ControllerAdditions
  end
end
