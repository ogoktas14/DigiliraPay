//
//  Localization.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 27.01.2021.
//  Copyright © 2021 DigiliraPay. All rights reserved.
//

import Foundation

class Localize: NSObject {
    
    enum keys: String {
        case touch_id_reason, attention, no_camera, an_error_occured, out_of_balance_header, fee_remark_unregistered, fee_remark_interwallets, not_digilirapay_wallet, out_of_balance_message, token_not_supported, x_token_balance_not_found, commision_info, cannot_send_x_token_to_x_network, cannot_find_a_valid_address, try_again, use_buttons_to_add_an_address, ammount_to_be_sent, deposit_to_send_tokens_message, deposit_to_send_tokens_header, total, min_transfer_amount, fee_remark_foreign, transfer_confirmation, check_your_transfer, confirm, reject, wrong_entry_header, profile_update_header, profile_update_message, qr_error_header, qr_error_message, new_terms_of_use_message, new_terms_of_use_title, new_legal_view_message, new_legal_view_title, check_the_information_entered, cannot_perform_this_action_try_again, do_not_take_screenshots, skip_this, verify, transfer_details, ok, cancel, read_and_agreed, received_transfer, sent_transfer, other, details, details_loading, address_copied, transfer_time, click_to_see_deta, transfer_type, receiver, sender, wallet_address_copied, withdraw, deposite, transaction_access_area, no_transaction, upload_selfie_info, soon
    }
 
    enum onBoardingView: String {
        case page_1_line_1, page_1_line_2, page_1_line_3
        case page_2_line_1, page_2_line_2, page_2_line_3
        case page_3_line_1, page_3_line_2, page_3_line_3
        case lets_start, import_account
    }
    
    enum letsStartVc: String {
        case start, continue_to, create_seed_keys, backed_up, verify_and_start
        case lets_page_1_line_1, lets_page_1_line_2, lets_page_1_line_3
        case lets_page_2_line_1, lets_page_2_line_2, lets_page_2_line_3
        case lets_page_3_line_1, lets_page_3_line_2, lets_page_3_line_3
        case last_page_header, last_page_message, last_page_desc, verify_and_start_message, skip_this
    }
    
    enum importAccountVals: String {
        case top_info, header_info, sub_header_info, bottom_info, back_button, start_button
    }
    
    enum pinScreen: String {
        case enter_the_pin, enter_a_pin, verify_pin, use_biometrics, remaining_wrong_entry, wrong_entry
    }
    
    enum drawerMenu: String {
        case verify_profile, seed, usage, legal_view, biometrics_touch_id, biometrics_face_id, biometrics_pin, pin_settings, bitexen_api, commissions, testnet, mainnet
    }
    
    enum mainScreen: String {
        case my_profile, pull_to_refresh, bitexen_api_not_verified, seed_warning, account_activated, account_blocked, account_verified, account_not_verified, account_updated, account_activated_message, account_blocked_message, account_verified_message, account_not_verified_message, account_updated_message, account_verify_in_progress, account_verify_in_progree_message,    account_verify_proceed_to_kyc
        case qr_code_is_invalid_message, qr_code_is_invalid, edit_account_details, account_active, select_a_qr_code, camera, gallery, cancel, transfer_between_digilira_users, free, transfer_to_waves, sending, receiving, cannot_send, transfer_to_gateway, commissions_info, verify_profile_to_proceed, biometric_verification_needed, you_will_be_notified, in_progress, token_not_supported, invalid_token, exclusive_payment, sending_x_token, verifying_transfer, transfer_successful, transfer_ok, gallery_permission, data_uploaded, your_profile_will_be_updated, uploading, selfie_uploading, upload_error_compression, upload_error_sizing, upload_error_try_again, invalid_wallet, invalid_wallet_message, x_blockchain_not_supported

    }
    
    enum messages: String {
        case abnormal_situation, missing_parameters, try_again, empty_auth, enter_amount, below_minimum, connection_problem, no_internet, access_denied, cannot_send_this_token, verify_profile_to_make_payment, cannot_pay_with_this_token, smart_account_not_allowed, blockchain_error, blockchain_error_message, blockchain_error_message_try_again, not_allowed_below_minimum, tel_missing, e_mail_missing, tc_missing, name_missing, surname_missing, undefined, alternatice_verification, verfication_error, profile_verified, checkmark_not_selected, verify_your_information, bitexen_api_saved_message, bitexen_api_saved_title, bitexen_not_avail, qr_not_avail, qr_not_valid, deposit_to_pay_message, deposit_to_pay_title, words_do_not_match, hide_words, show_words, verify, no_one_knows_your_seed, if_backed, one_tower_message, add_bitexen_message, add_bitexen
    }
    
    enum depositVc: String {
        case qr_saved,qr_saved_title, gallery_permission, deposit_info_1, deposit_info_2, deposit_info_3
    }
    public func getLocalizedString(_ key: String) -> String{
        return NSLocalizedString(key, comment: "")
    }
    
    //setLang(Localize.mainScreen.edit_account_details.rawValue)
}
