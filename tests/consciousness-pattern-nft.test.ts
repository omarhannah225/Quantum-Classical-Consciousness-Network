import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mint(name: string, description: string, patternHash: string, achievementType: string, creator: string) {
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    name,
    description,
    creator,
    patternHash,
    achievementType,
    timestamp: Date.now()
  });
  tokenOwners.set(tokenId, creator);
  return tokenId;
}

function transfer(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Consciousness Pattern NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new consciousness pattern NFT', () => {
    const tokenId = mint('Alpha Wave Pattern', 'First successful consciousness transfer pattern', '0x1234567890abcdef', 'Transfer Achievement', 'researcher1');
    expect(tokenId).toBe(1);
    expect(tokenOwners.get(tokenId)).toBe('researcher1');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.name).toBe('Alpha Wave Pattern');
    expect(metadata.achievementType).toBe('Transfer Achievement');
  });
  
  it('should transfer an NFT', () => {
    const tokenId = mint('Quantum Entanglement Pattern', 'Consciousness pattern using quantum entanglement', '0xabcdef1234567890', 'Quantum Achievement', 'researcher2');
    expect(transfer(tokenId, 'researcher2', 'researcher3')).toBe(true);
    expect(tokenOwners.get(tokenId)).toBe('researcher3');
  });
  
  it('should not allow unauthorized transfer', () => {
    const tokenId = mint('Neural Network Mapping', 'Consciousness mapped to artificial neural network', '0x9876543210fedcba', 'AI Integration', 'researcher4');
    expect(() => transfer(tokenId, 'unauthorized_user', 'researcher5')).toThrow('Not authorized');
  });
  
  it('should store correct metadata', () => {
    const patternHash = '0xfedcba9876543210';
    const tokenId = mint('Bioelectric Field Pattern', 'Consciousness pattern in bioelectric fields', patternHash, 'Biological Integration', 'researcher6');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.patternHash).toBe(patternHash);
    expect(metadata.creator).toBe('researcher6');
    expect(metadata.timestamp).toBeLessThanOrEqual(Date.now());
  });
});

