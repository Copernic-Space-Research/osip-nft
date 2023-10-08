// returns address from txr from PayloadFactory.create

import { ContractTransactionReceipt, EventLog } from "ethers";

/**
 * helper to parse tx receipt and find first payload factory event
 * 'PayloadCreated' to get new address of PayloadContract
 *
 * @param txr transaction receipt
 * @returns address of new payload contract created via factory
 */
export const getAssetAddress = (
  txr: ContractTransactionReceipt
): string | undefined =>
  txr.logs
    .filter((l) => l instanceof EventLog)
    .map((e) => e as EventLog)
    .filter((e) => e.eventName === "AssetCreated")
    .map((e) => e.args[0])
    .pop();
