class ApplicationController < ActionController::Base

    # TODO put in place correctly - but until then its just fALSE
    # mutations_allowed?
    def logged_in?
        false
    end

    # same here
    def mutations_allowed?
        false
    end
    helper_method :mutations_allowed?
    helper_method :logged_in?

end
