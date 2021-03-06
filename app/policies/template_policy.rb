# frozen_string_literal: true

class TemplatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(enabled: true).or(scope.where(user: user))
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def update?
    user.admin? || record.user == user
  end

  def count?
    update?
  end
end
