module Can4
  # Ability class for resources.
  #
  # To define an ability model for your resource, define an ability class in
  # a location of your choosing, and define the actions available to the
  # resource on construction.
  #
  # @example
  #   class Ability < Can4::Ability
  #     def initialize(user)
  #       # Handle unauthenticated users.
  #       user ||= User.new
  #
  #       if user.admin?
  #         # Allow admins to perform any action.
  #         allow_anything!
  #       else
  #         # Will always return true for can?(:read, @comment).
  #         can :read, Comment
  #
  #         # Will only return true for can?(:read, @private_message)
  #         # if the user is allowed to read the private message.
  #         can :read, PrivateMessage do |msg|
  #           msg.user_id == user.id
  #         end
  #       end
  #     end
  #   end
  #
  class Ability
    # Checks whether the object can perform an action on a subject.
    #
    # @overload can?(action, subject)
    #   @param action [Symbol] The action, represented as a symbol.
    #   @param subject [Object] The subject.
    # @overload can?(action, subject, *args)
    #   @param action [Symbol] The action, represented as a symbol.
    #   @param subject [Object] The subject.
    #   @param args [Object] Splat parameters to an installed block.
    # @return [Boolean] True or false.
    def can?(action, subject, *args)
      lookup_rule(subject).authorized?(action, subject, args)
    end

    # Inverse of #can?.
    #
    # @see #can?
    def cannot?(*args)
      !can?(*args)
    end

    # Adds an access-granting rule.
    #
    # @param action [Symbol] The action, represented as a symbol.
    # @param subject [Object] The subject.
    # @param block [Proc] An optional Proc to install for matching.
    def can(action, subject, &block)
      rule_for(subject).add_grant(action, block)
    end

    # Allows the object to perform any action on any subject.
    # This overrides all #cannot rules.
    def allow_anything!
      instance_eval do
        def can?(*)
          true
        end

        def cannot?(*)
          false
        end
      end
    end

    # Checks whether this resource has authorization to perform an action on a
    # particular subject. Raises {Can4::AccessDenied} if it doesn't.
    #
    # @param action [Symbol] The intended action.
    # @param subject [Object] The subject of the action.
    # @raise [AccessDenied] if the object does not have permission.
    def authorize!(action, subject, *args)
      raise AccessDenied if cannot?(action, subject, *args)
    end

    protected

    # Subjects hash.
    def subjects
      @subjects ||= {}
    end

    # Find or create a new rule for the specified subject.
    #
    # @param subject [Object] The subject.
    def rule_for(subject)
      subjects[subject] ||= SubjectRule.new
    end

    # Lookup a rule for a particular subject.
    #
    # @param subject [Object] The subject.
    def lookup_rule(subject)
      case subject
      when Symbol, Module
        subjects[subject] || NullRule
      else
        subjects[subject.class] || NullRule
      end
    end
  end
end
