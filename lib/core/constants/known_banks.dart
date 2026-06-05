import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/financial_institution.dart';

/// Curated list of banks. [slug] must match the PNG filename in assets/banks/.
/// [brandColor] is the hex used as card background when no PNG asset exists.
class KnownBank {
  final String slug;
  final String displayName;
  final String brandColor;
  final String country; // ISO 3166-1 alpha-2, '' = international

  const KnownBank({
    required this.slug,
    required this.displayName,
    required this.brandColor,
    this.country = '',
  });

  /// Asset path for the card skin PNG.
  String get assetPath => 'assets/banks/$slug.png';

  /// Returns the institution value stored on the BankAccount entity.
  /// WalletCard derives the slug from this string automatically.
  String get institutionValue => displayName;
}

/// Returns slug from an arbitrary institution string (mirrors WalletCard logic).
String bankSlug(String institution) => institution
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

extension KnownBankToInstitution on KnownBank {
  /// Convert a [KnownBank] constant to a [FinancialInstitution] seed entity.
  /// [id] should be a stable UUID (from DB seed or local generation).
  FinancialInstitution toInstitution(String id) => FinancialInstitution(
        id: id,
        name: displayName,
        slug: slug,
        country: country,
        brandColor: brandColor,
        logoAsset: 'assets/banks/$slug.png',
        institutionType: InstitutionType.bank,
        isCustom: false,
      );
}

const List<KnownBank> kKnownBanks = [
  // ── Spain ────────────────────────────────────────────────────────────────
  KnownBank(
      slug: 'bbva', displayName: 'BBVA', brandColor: '#004B96', country: 'ES'),
  KnownBank(
      slug: 'santander',
      displayName: 'Santander',
      brandColor: '#EC0000',
      country: 'ES'),
  KnownBank(
      slug: 'caixabank',
      displayName: 'CaixaBank',
      brandColor: '#007BC4',
      country: 'ES'),
  KnownBank(
      slug: 'la_caixa',
      displayName: 'La Caixa',
      brandColor: '#007BC4',
      country: 'ES'),
  KnownBank(
      slug: 'imaginbank',
      displayName: 'ImaginBank',
      brandColor: '#6B3FCA',
      country: 'ES'),
  KnownBank(
      slug: 'banco_sabadell',
      displayName: 'Banco Sabadell',
      brandColor: '#0065A4',
      country: 'ES'),
  KnownBank(
      slug: 'bankinter',
      displayName: 'Bankinter',
      brandColor: '#FF6900',
      country: 'ES'),
  KnownBank(
      slug: 'openbank',
      displayName: 'Openbank',
      brandColor: '#EC0000',
      country: 'ES'),
  KnownBank(
      slug: 'kutxabank',
      displayName: 'Kutxabank',
      brandColor: '#003DA5',
      country: 'ES'),
  KnownBank(
      slug: 'ibercaja',
      displayName: 'Ibercaja',
      brandColor: '#C8102E',
      country: 'ES'),
  KnownBank(
      slug: 'unicaja',
      displayName: 'Unicaja',
      brandColor: '#005A8B',
      country: 'ES'),
  KnownBank(
      slug: 'abanca',
      displayName: 'Abanca',
      brandColor: '#00A0DF',
      country: 'ES'),
  KnownBank(
      slug: 'cajamar',
      displayName: 'Cajamar',
      brandColor: '#005F9E',
      country: 'ES'),
  KnownBank(
      slug: 'myinvestor',
      displayName: 'MyInvestor',
      brandColor: '#1A1A2E',
      country: 'ES'),
  KnownBank(
      slug: 'evo_banco',
      displayName: 'EVO Banco',
      brandColor: '#00B140',
      country: 'ES'),
  KnownBank(
      slug: 'banco_mediolanum',
      displayName: 'Banco Mediolanum',
      brandColor: '#D4002A',
      country: 'ES'),
  KnownBank(
      slug: 'wizink',
      displayName: 'WiZink',
      brandColor: '#6D1F7E',
      country: 'ES'),
  KnownBank(
      slug: 'cofidis',
      displayName: 'Cofidis',
      brandColor: '#E2001A',
      country: 'ES'),
  KnownBank(
      slug: 'cetelem',
      displayName: 'Cetelem',
      brandColor: '#009B3A',
      country: 'ES'),

  // ── Europe / International ────────────────────────────────────────────────
  KnownBank(slug: 'revolut', displayName: 'Revolut', brandColor: '#191C1F'),
  KnownBank(slug: 'wise', displayName: 'Wise', brandColor: '#00B9A3'),
  KnownBank(slug: 'n26', displayName: 'N26', brandColor: '#26282B'),
  KnownBank(
      slug: 'ing', displayName: 'ING', brandColor: '#FF6200', country: 'NL'),
  KnownBank(
      slug: 'monzo',
      displayName: 'Monzo',
      brandColor: '#FF3362',
      country: 'GB'),
  KnownBank(
      slug: 'starling',
      displayName: 'Starling Bank',
      brandColor: '#6935D3',
      country: 'GB'),
  KnownBank(
      slug: 'bunq', displayName: 'bunq', brandColor: '#00A6B4', country: 'NL'),
  KnownBank(
      slug: 'trade_republic',
      displayName: 'Trade Republic',
      brandColor: '#0DBF8C'),
  KnownBank(
      slug: 'scalable_capital',
      displayName: 'Scalable Capital',
      brandColor: '#00C4A0'),
  KnownBank(slug: 'degiro', displayName: 'DEGIRO', brandColor: '#ED6B00'),
  KnownBank(slug: 'paypal', displayName: 'PayPal', brandColor: '#003087'),
  KnownBank(slug: 'klarna', displayName: 'Klarna', brandColor: '#FFB3C7'),
  KnownBank(
      slug: 'deutsche_bank',
      displayName: 'Deutsche Bank',
      brandColor: '#003189',
      country: 'DE'),
  KnownBank(
      slug: 'commerzbank',
      displayName: 'Commerzbank',
      brandColor: '#FFD100',
      country: 'DE'),
  KnownBank(
      slug: 'bnp_paribas',
      displayName: 'BNP Paribas',
      brandColor: '#00915A',
      country: 'FR'),
  KnownBank(
      slug: 'credit_agricole',
      displayName: 'Crédit Agricole',
      brandColor: '#006A4E',
      country: 'FR'),
  KnownBank(
      slug: 'societe_generale',
      displayName: 'Société Générale',
      brandColor: '#E60028',
      country: 'FR'),
  KnownBank(
      slug: 'barclays',
      displayName: 'Barclays',
      brandColor: '#00AEEF',
      country: 'GB'),
  KnownBank(
      slug: 'hsbc', displayName: 'HSBC', brandColor: '#DB0011', country: 'GB'),
  KnownBank(
      slug: 'lloyds',
      displayName: 'Lloyds Bank',
      brandColor: '#024731',
      country: 'GB'),
  KnownBank(
      slug: 'natwest',
      displayName: 'NatWest',
      brandColor: '#5A287F',
      country: 'GB'),
  KnownBank(
      slug: 'unicredit',
      displayName: 'UniCredit',
      brandColor: '#CC0000',
      country: 'IT'),
  KnownBank(
      slug: 'intesa_sanpaolo',
      displayName: 'Intesa Sanpaolo',
      brandColor: '#1E5FA8',
      country: 'IT'),
  KnownBank(
      slug: 'rabobank',
      displayName: 'Rabobank',
      brandColor: '#FF7900',
      country: 'NL'),
  KnownBank(
      slug: 'abn_amro',
      displayName: 'ABN AMRO',
      brandColor: '#005B82',
      country: 'NL'),

  // ── USA ───────────────────────────────────────────────────────────────────
  KnownBank(
      slug: 'chase',
      displayName: 'Chase',
      brandColor: '#117ACA',
      country: 'US'),
  KnownBank(
      slug: 'bank_of_america',
      displayName: 'Bank of America',
      brandColor: '#E31837',
      country: 'US'),
  KnownBank(
      slug: 'wells_fargo',
      displayName: 'Wells Fargo',
      brandColor: '#D71E28',
      country: 'US'),
  KnownBank(
      slug: 'citi', displayName: 'Citi', brandColor: '#003B8E', country: 'US'),
  KnownBank(
      slug: 'american_express',
      displayName: 'American Express',
      brandColor: '#016FD0',
      country: 'US'),

  // ── Crypto / Digital ─────────────────────────────────────────────────────
  KnownBank(slug: 'coinbase', displayName: 'Coinbase', brandColor: '#0052FF'),
  KnownBank(slug: 'binance', displayName: 'Binance', brandColor: '#F0B90B'),

  // ── Generic ───────────────────────────────────────────────────────────────
  KnownBank(slug: 'cash', displayName: 'Cash', brandColor: '#22C55E'),
  KnownBank(slug: 'other', displayName: 'Other', brandColor: '#64748B'),
];
