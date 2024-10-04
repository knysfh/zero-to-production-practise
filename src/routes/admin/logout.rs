use actix_web::{web, HttpResponse};
use actix_web_flash_messages::FlashMessage;

use crate::{authentication::UserId, session_state::TypedSession, utils::see_other};

pub async fn log_out(
    user_id: web::ReqData<UserId>,
    session: TypedSession,
) -> Result<HttpResponse, actix_web::Error> {
    let user_id = user_id.into_inner();
    if user_id.is_nil() {
        Ok(see_other("/login"))
    } else {
        session.log_out();
        FlashMessage::info("You have successfully logged out.").send();
        Ok(see_other("/login"))
    }
}
