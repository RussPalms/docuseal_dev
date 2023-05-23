# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'dashboard#index'

  devise_for :users, path: '/', only: %i[sessions passwords]

  devise_scope :user do
    if User.devise_modules.include?(:registerable)
      resource :registration, only: %i[create], path: 'sign_up' do
        get '' => :new, as: :new
      end
    end

    resource :invitation, only: %i[update] do
      get '' => :edit
    end
  end

  namespace :api do
    resources :attachments, only: %i[create]
    resources :flows, only: %i[update] do
      resources :documents, only: %i[create destroy], controller: 'flows_documents'
    end
  end

  resources :dashboard, only: %i[index]
  resources :setup, only: %i[index create]
  resources :users, only: %i[new create edit update destroy]
  resources :submissions, only: %i[show destroy]
  resources :flows, only: %i[new create show destroy] do
    resources :submissions, only: %i[index new create]
  end

  resources :start_flow, only: %i[show update], path: 'f', param: 'slug' do
    get :completed
  end

  resources :submit_flow, only: %i[show update], path: 'l', param: 'slug' do
    get :completed
  end

  resources :send_submission_email, only: %i[create] do
    get :success, on: :collection
  end

  resources :submissions, only: %i[], param: 'slug' do
    resources :download, only: %i[index], controller: 'submissions_download'
  end

  scope '/settings', as: :settings do
    resources :storage, only: %i[index create], controller: 'storage_settings'
    resources :email, only: %i[index create], controller: 'email_settings'
    resources :users, only: %i[index]
  end
end