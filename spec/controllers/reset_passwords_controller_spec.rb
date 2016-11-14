# frozen_string_literal: true
require 'rails_helper'

describe ResetPasswordsController do
  let(:authentication) { instance_double(MemberAuthentication, set_reset_password_token: true, confirm: true) }
  let(:mailer) { double(deliver_now: true) }

  describe 'GET new' do
    it 'renders new' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'GET edit' do
    context 'with valid token' do
      before do
        allow(MemberAuthentication).to receive(:find_by_valid_reset_password_token) { authentication }
        get :edit, token: '1234'
      end

      it 'finds authentication by reset_password_token' do
        expect(MemberAuthentication).to have_received(:find_by_valid_reset_password_token)
          .with('1234')
      end

      it 'confirms authentication' do
        expect(authentication).to have_received(:confirm)
      end

      it 'renders edit' do
        expect(response).to render_template('edit')
      end
    end

    context 'with invalid token' do
      before do
        allow(MemberAuthentication).to receive(:find_by_valid_reset_password_token) { nil }
        get :edit, token: '1234'
      end

      it 'finds authentication by reset_password_token' do
        expect(MemberAuthentication).to have_received(:find_by_valid_reset_password_token)
          .with('1234')
      end

      it 'does not confirm authentication' do
        expect(authentication).not_to have_received(:confirm)
      end

      it 'redirects to new action' do
        expect(response).to redirect_to(new_reset_password_path)
        expect(flash[:alert]).to match(/invalid password reset link/)
      end
    end
  end

  describe 'PUT update' do
    context 'successfully resets password' do
      before do
        allow(MemberAuthentication).to receive(:find_by) { authentication }
        allow(authentication).to receive(:reset_password) { true }
        put :update, token: '1234', password: 'password', password_confirmation: 'password'
      end

      it 'finds member authentication' do
        expect(MemberAuthentication).to have_received(:find_by)
          .with(reset_password_token: '1234')
      end

      it 'successfully resets password' do
        expect(authentication).to have_received(:reset_password)
          .with('password', 'password')
      end

      it 'renders success' do
        expect(response).to render_template('success')
      end
    end

    context 'does not successfully reset password' do
      before do
        allow(MemberAuthentication).to receive(:find_by) { authentication }
        allow(authentication).to receive(:reset_password) { false }
        put :update, token: '1234', password: 'password', password_confirmation: 'password'
      end

      it 'renders edit' do
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'POST create' do
    before do
      allow(ResetPasswordMailer).to receive(:reset_password_email) { mailer }
    end

    context 'with valid token' do
      before do
        allow(MemberAuthentication).to receive(:find_by_email) { authentication }
        post :create, email: 'test@example.com'
      end

      it 'finds member authentication' do
        expect(MemberAuthentication).to have_received(:find_by_email)
          .with('test@example.com')
      end

      it 'delivers email' do
        expect(ResetPasswordMailer).to have_received(:reset_password_email)
          .with(authentication)

        expect(mailer).to have_received(:deliver_now)
      end

      it 'renders show' do
        expect(response).to render_template('show')
      end
    end

    context 'with invalid token' do
      before do
        allow(MemberAuthentication).to receive(:find_by_email) { nil }
        post :create, email: 'test@example.com'
      end

      it 'finds member authentication' do
        expect(MemberAuthentication).to have_received(:find_by_email)
          .with('test@example.com')
      end

      it 'does not deliver email' do
        expect(ResetPasswordMailer).not_to have_received(:reset_password_email)
          .with(authentication)
      end

      it 'renders new' do
        expect(response).to render_template('new')
        expect(flash[:alert]).to match(/[Cc]an't find that email/)
      end
    end
  end
end
