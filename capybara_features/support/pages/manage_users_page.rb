class ManageUsersPage

  def initialize(session)
    @session = session
  end

  def should_show_users_in_order(expected_user_names)
    actual_user_names.should == expected_user_names
  end

private

  def actual_user_names
    @session.all(:xpath, "//td[@class='full_name']").collect(&:text)
  end
end
