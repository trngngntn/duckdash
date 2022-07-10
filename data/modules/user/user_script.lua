local nkm = require('nakama')

local const PERM_NO_READ = 0
local const PERM_OWNER_READ = 1
local const PERM_PUBLIC_READ = 2

local const PERM_NO_WRITE = 0
local const PERM_OWNER_WRITE = 1

local function create_storage_obj(collection, key, user_id, value, perm_read, perm_write)
    return {
        collection = collection,
        key = key,
        user_id = user_id,
        value = value,
        permission_read = perm_read,
        permission_write = perm_write
    }
end

local function initialize_user(context, payload)
    if payload.created then
        local changeset = {
            gold = 0,
            soul = 0
        }
        local metadata = {}
        nkm.wallet_update(context.user_id, changeset, metadata, true)

        local exp_storage_write = create_storage_obj("stats", "exp", context.user_id, {['value'] = 0}, PERM_OWNER_READ, PERM_NO_WRITE)
        local skp_storage_write = create_storage_obj("stats", "skp", context.user_id, {['value'] = 5}, PERM_OWNER_READ, PERM_NO_WRITE)
        local lvl_storage_write = create_storage_obj("stats", "lvl", context.user_id, {['value'] = 0}, PERM_PUBLIC_READ, PERM_NO_WRITE)

        nkm.storage_write({
            exp_storage_write,
            skp_storage_write,
            lvl_storage_write
        })
    end
end

nkm.register_req_after(initialize_user, "AuthenticateEmail")

local function get_user_inventory(context, payload)
    local uid = context.user_id
    local list = nkm.storage_list(uid, "inventory", 100, "")
end