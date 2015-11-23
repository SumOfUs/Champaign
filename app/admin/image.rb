ActiveAdmin.register Image do
  actions :all, except: [:new, :edit, :destroy]
end
