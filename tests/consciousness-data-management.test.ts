import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let consciousnessDataCount = 0;
const consciousnessData = new Map();

// Simulated contract functions
function registerConsciousnessData(dataHash: string, owner: string) {
  const dataId = ++consciousnessDataCount;
  consciousnessData.set(dataId, {
    owner,
    dataHash,
    timestamp: Date.now(),
    status: 'registered'
  });
  return dataId;
}

function updateConsciousnessDataStatus(dataId: number, newStatus: string, updater: string) {
  const data = consciousnessData.get(dataId);
  if (!data) throw new Error('Invalid data');
  if (updater !== 'CONTRACT_OWNER' && updater !== data.owner) throw new Error('Not authorized');
  data.status = newStatus;
  consciousnessData.set(dataId, data);
  return true;
}

describe('Consciousness Data Management Contract', () => {
  beforeEach(() => {
    consciousnessDataCount = 0;
    consciousnessData.clear();
  });
  
  it('should register new consciousness data', () => {
    const dataId = registerConsciousnessData('0x1234567890abcdef', 'user1');
    expect(dataId).toBe(1);
    expect(consciousnessData.size).toBe(1);
    const data = consciousnessData.get(dataId);
    expect(data.dataHash).toBe('0x1234567890abcdef');
    expect(data.status).toBe('registered');
  });
  
  it('should update consciousness data status', () => {
    const dataId = registerConsciousnessData('0xabcdef1234567890', 'user2');
    expect(updateConsciousnessDataStatus(dataId, 'verified', 'CONTRACT_OWNER')).toBe(true);
    const data = consciousnessData.get(dataId);
    expect(data.status).toBe('verified');
  });
  
  it('should not allow unauthorized status updates', () => {
    const dataId = registerConsciousnessData('0x9876543210fedcba', 'user3');
    expect(() => updateConsciousnessDataStatus(dataId, 'verified', 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should allow owner to update status', () => {
    const dataId = registerConsciousnessData('0xfedcba9876543210', 'user4');
    expect(updateConsciousnessDataStatus(dataId, 'processing', 'user4')).toBe(true);
    const data = consciousnessData.get(dataId);
    expect(data.status).toBe('processing');
  });
});

